#!/usr/bin/env python3
"""gfishimage - 手绘风格图片生成器（兼容任意 Gemini 协议 API）。

用法:
    # 首次配置
    python generate_ikun.py --setup

    # 单张生成
    python generate_ikun.py --prompt "描述" [--aspect-ratio 16:9] [--size 2K] \
                            [--output ./output.png] [--retry 3]

    # 并发批量生成
    python generate_ikun.py --batch tasks.json [--workers 2] [--retry 3]
"""

import argparse
import base64
import json
import os
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

try:
    import httpx
except ImportError:
    print("错误: 需要 httpx 库，请执行: pip install httpx", file=sys.stderr)
    sys.exit(1)

# ---------------------------------------------------------------------------
# 配置路径
# ---------------------------------------------------------------------------

CONFIG_DIR = Path.home() / ".gfishimage"
CONFIG_FILE = CONFIG_DIR / "config.json"

# 默认值（用户可通过 --setup 自定义）
DEFAULT_BASE_URL = "https://your-api-endpoint.example.com"
DEFAULT_MODEL = "your-model-name"

# ---------------------------------------------------------------------------
# 常量
# ---------------------------------------------------------------------------

VALID_ASPECT_RATIOS = [
    "1:1", "16:9", "9:16", "4:3", "3:4",
    "3:2", "2:3", "21:9", "5:4", "4:5",
]

VALID_SIZES = ["1K", "2K", "4K"]

TIMEOUT_MAP = {"1K": 360, "2K": 600, "4K": 1200}

RETRYABLE_STATUS_CODES = {429, 500, 502, 503, 504}

_print_lock = threading.Lock()


def _safe_print(msg, *, file=None):
    """线程安全的打印。"""
    with _print_lock:
        print(msg, file=file or sys.stdout, flush=True)


# ---------------------------------------------------------------------------
# API Key 管理
# ---------------------------------------------------------------------------

def _load_config() -> dict:
    """从配置文件加载配置，文件不存在或解析失败返回空 dict。"""
    if not CONFIG_FILE.exists():
        return {}
    try:
        return json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return {}


def _save_config(config: dict) -> None:
    """将配置写入配置文件。"""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    CONFIG_FILE.write_text(
        json.dumps(config, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def resolve_api_key(cli_key: str | None = None) -> str:
    """按优先级解析 API Key。

    优先级：CLI --api-key > G_FISH_IMAGE_API_KEY 环境变量 > 配置文件 > 报错退出。
    """
    # 1. CLI 参数
    if cli_key:
        return cli_key

    # 2. 环境变量
    env_key = os.environ.get("G_FISH_IMAGE_API_KEY", "").strip()
    if env_key:
        return env_key

    # 3. 配置文件
    config = _load_config()
    file_key = config.get("api_key", "").strip()
    if file_key:
        return file_key

    # 4. 均无 → 报错
    print(
        "错误: 未找到 API Key。请通过以下方式之一配置：\n"
        f"  1. 运行 python {Path(__file__).name} --setup 进行交互式配置\n"
        f"  2. 手动创建 {CONFIG_FILE}，内容: {{\"api_key\": \"sk-xxx\"}}\n"
        "  3. 设置环境变量 G_FISH_IMAGE_API_KEY=sk-xxx\n"
        "  4. 使用 --api-key sk-xxx 命令行参数",
        file=sys.stderr,
    )
    sys.exit(1)


def resolve_base_url() -> str:
    """从配置文件读取 base_url，不存在则用默认值。"""
    config = _load_config()
    return config.get("base_url", "").strip() or DEFAULT_BASE_URL


def resolve_model() -> str:
    """从配置文件读取 model，不存在则用默认值。"""
    config = _load_config()
    return config.get("model", "").strip() or DEFAULT_MODEL


def run_setup() -> None:
    """交互式引导创建配置文件。"""
    print("=" * 50)
    print("  gfishimage 配置向导")
    print("=" * 50)
    print(f"\n配置文件位置: {CONFIG_FILE}\n")

    existing = _load_config()
    if existing.get("api_key"):
        masked = existing["api_key"][:6] + "..." + existing["api_key"][-4:]
        print(f"当前已有配置:")
        print(f"  API Key:  {masked}")
        print(f"  Base URL: {existing.get('base_url', DEFAULT_BASE_URL)}")
        print(f"  Model:    {existing.get('model', DEFAULT_MODEL)}")
        confirm = input("\n是否覆盖？(y/N): ").strip().lower()
        if confirm not in ("y", "yes"):
            print("已取消。")
            return

    print("\n请输入以下配置项（直接回车使用默认值）：\n")

    base_url = input(f"API Base URL [{DEFAULT_BASE_URL}]: ").strip()
    if not base_url:
        base_url = DEFAULT_BASE_URL

    api_key = input("API Key (sk-xxx): ").strip()
    if not api_key:
        print("错误: API Key 不能为空。", file=sys.stderr)
        sys.exit(1)

    model = input(f"生图模型名称 [{DEFAULT_MODEL}]: ").strip()
    if not model:
        model = DEFAULT_MODEL

    config = existing.copy()
    config["base_url"] = base_url
    config["api_key"] = api_key
    config["model"] = model
    _save_config(config)

    print(f"\n配置已保存到 {CONFIG_FILE}")
    print("现在可以使用 gfishimage 生成图片了。")


# ---------------------------------------------------------------------------
# 请求构建与发送
# ---------------------------------------------------------------------------

def build_payload(prompt: str, aspect_ratio: str, image_size: str) -> dict:
    return {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {
                "aspectRatio": aspect_ratio,
                "image_size": image_size,
            },
        },
    }


def _request_once(payload: dict, timeout: int, api_key: str) -> httpx.Response:
    """发送单次 API 请求。"""
    base_url = resolve_base_url()
    model = resolve_model()
    url = f"{base_url.rstrip('/')}/v1beta/models/{model}:generateContent"
    with httpx.Client(timeout=timeout) as client:
        return client.post(
            url,
            json=payload,
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
        )


# ---------------------------------------------------------------------------
# 核心生成逻辑（线程安全，不调用 sys.exit）
# ---------------------------------------------------------------------------

def _generate_core(
    prompt: str,
    api_key: str,
    aspect_ratio: str = "1:1",
    image_size: str = "2K",
    output_path: str = "output.png",
    max_retries: int = 3,
    task_label: str = "",
) -> dict:
    """生成单张图片，返回结果字典。线程安全，不会调用 sys.exit。

    返回:
        成功: {"success": True, "path": str, "size_kb": float, "elapsed": float}
        失败: {"success": False, "error": str}
    """
    tag = f"[ikunimage{' ' + task_label if task_label else ''}]"
    payload = build_payload(prompt, aspect_ratio, image_size)
    timeout = TIMEOUT_MAP.get(image_size, 600)

    _safe_print(f"{tag} 正在生成图片...")
    _safe_print(f"{tag}   宽高比: {aspect_ratio} | 分辨率: {image_size} | 超时: {timeout}s")

    resp = None
    last_error = None

    for attempt in range(max_retries + 1):
        if attempt > 0:
            delay = min(2 ** attempt, 60)
            _safe_print(f"{tag} 第 {attempt}/{max_retries} 次重试，等待 {delay}s ...")
            time.sleep(delay)

        _safe_print(f"{tag} 发送请求 (attempt {attempt + 1})")

        t0 = time.time()
        try:
            resp = _request_once(payload, timeout, api_key)
        except httpx.TimeoutException:
            last_error = "请求超时"
            _safe_print(f"{tag} 请求超时", file=sys.stderr)
            continue
        except httpx.ConnectError as e:
            last_error = f"连接失败: {e}"
            _safe_print(f"{tag} 连接失败: {e}", file=sys.stderr)
            continue

        elapsed = time.time() - t0

        if resp.status_code == 200:
            _safe_print(f"{tag} API 响应成功，耗时 {elapsed:.1f}s")
            break

        if resp.status_code in RETRYABLE_STATUS_CODES and attempt < max_retries:
            try:
                err_body = resp.json()
                err_msg = err_body.get("error", {}).get("message", resp.text[:200])
            except Exception:
                err_msg = resp.text[:200]
            last_error = f"HTTP {resp.status_code}: {err_msg}"
            _safe_print(f"{tag} 收到 {resp.status_code}，将重试", file=sys.stderr)
            continue

        # 不可重试
        try:
            err_detail = json.dumps(resp.json(), indent=2, ensure_ascii=False)[:500]
        except Exception:
            err_detail = resp.text[:500]
        return {"success": False, "error": f"HTTP {resp.status_code}: {err_detail}"}
    else:
        return {"success": False, "error": f"重试 {max_retries} 次仍然失败。最后错误: {last_error}"}

    # 解析响应
    data = resp.json()
    try:
        parts = data["candidates"][0]["content"]["parts"]
        image_part = next(p for p in parts if "inlineData" in p)
        b64_data = image_part["inlineData"]["data"]
        mime_type = image_part["inlineData"].get("mimeType", "image/png")
    except (KeyError, IndexError, StopIteration):
        snippet = json.dumps(data, indent=2, ensure_ascii=False)[:500]
        return {"success": False, "error": f"API 响应中未找到图片数据: {snippet}"}

    image_bytes = base64.b64decode(b64_data)

    out = Path(output_path)
    if not out.suffix:
        ext = mime_type.split("/")[-1].replace("jpeg", "jpg")
        out = out.with_suffix(f".{ext}")

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(image_bytes)

    size_kb = len(image_bytes) / 1024
    _safe_print(f"{tag} 生成完成，大小 {size_kb:.0f}KB -> {out}")

    return {
        "success": True,
        "path": str(out),
        "size_kb": round(size_kb, 1),
        "elapsed": round(elapsed, 1),
    }


# ---------------------------------------------------------------------------
# 单张生成（CLI 单图模式）
# ---------------------------------------------------------------------------

def generate(
    prompt: str,
    api_key: str,
    aspect_ratio: str = "1:1",
    image_size: str = "2K",
    output_path: str = "output.png",
    max_retries: int = 3,
) -> str:
    """单张生成入口，失败时 sys.exit(1)。"""
    result = _generate_core(
        prompt=prompt,
        api_key=api_key,
        aspect_ratio=aspect_ratio,
        image_size=image_size,
        output_path=output_path,
        max_retries=max_retries,
    )
    if not result["success"]:
        print(f"错误: {result['error']}", file=sys.stderr)
        sys.exit(1)
    return result["path"]


# ---------------------------------------------------------------------------
# 并发批量生成
# ---------------------------------------------------------------------------

def generate_batch(
    tasks: list,
    api_key: str,
    workers: int = 0,
    max_retries: int = 3,
) -> list:
    """并发批量生成多张图片。

    参数:
        tasks: 任务列表，每个元素为 dict:
            {
                "prompt": str,           # 必填
                "aspect_ratio": str,     # 可选，默认 "1:1"
                "size": str,             # 可选，默认 "2K"
                "output": str,           # 必填
            }
        api_key: ikun API Key
        workers: 并发数。0 = 自动（默认 2）
        max_retries: 每个任务的最大重试次数

    返回:
        与 tasks 等长的结果列表，每个元素为 _generate_core 的返回值，
        额外附加 "index" 字段表示原始任务序号。
    """
    num_tasks = len(tasks)

    if workers <= 0:
        workers = min(num_tasks, 2)
    workers = max(1, min(workers, num_tasks))

    print(f"[ikunimage 批量] 共 {num_tasks} 个任务，并发数: {workers}")

    t_start = time.time()
    results = [None] * num_tasks

    def _run_task(index: int, task: dict) -> tuple:
        result = _generate_core(
            prompt=task["prompt"],
            api_key=api_key,
            aspect_ratio=task.get("aspect_ratio", "1:1"),
            image_size=task.get("size", "2K"),
            output_path=task["output"],
            max_retries=max_retries,
            task_label=f"#{index + 1}",
        )
        result["index"] = index
        return index, result

    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {
            pool.submit(_run_task, i, t): i
            for i, t in enumerate(tasks)
        }
        for future in as_completed(futures):
            idx, result = future.result()
            results[idx] = result
            status = "OK" if result["success"] else "FAIL"
            _safe_print(f"[ikunimage 批量] 任务 #{idx + 1} {status}")

    t_total = time.time() - t_start
    ok = sum(1 for r in results if r and r["success"])
    print(f"\n[ikunimage 批量] 全部完成: {ok}/{num_tasks} 成功，总耗时 {t_total:.1f}s")

    return results


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="ikunimage - NanoBananaPro 图片生成器（ikun 渠道）",
    )

    # 配置子命令
    parser.add_argument(
        "--setup", action="store_true",
        help="交互式引导创建配置文件",
    )

    # API Key
    parser.add_argument(
        "--api-key", default=None,
        help="API Key（优先级高于环境变量和配置文件）",
    )

    # 单图模式参数
    parser.add_argument("--prompt", "-p", default=None, help="图片描述提示词（单图模式）")
    parser.add_argument(
        "--aspect-ratio", "-ar", default="1:1",
        choices=VALID_ASPECT_RATIOS, help="宽高比（默认: 1:1）",
    )
    parser.add_argument(
        "--size", "-s", default="2K",
        choices=VALID_SIZES, help="分辨率等级（默认: 2K）",
    )
    parser.add_argument(
        "--output", "-o", default="output.png", help="输出文件路径",
    )

    # 批量模式参数
    parser.add_argument(
        "--batch", "-b", default=None, metavar="JSON_FILE",
        help="批量任务 JSON 文件路径（与 --prompt 互斥）",
    )
    parser.add_argument(
        "--workers", "-w", type=int, default=0,
        help="并发 worker 数（默认: 自动）",
    )

    # 通用参数
    parser.add_argument(
        "--retry", "-r", type=int, default=3,
        choices=range(0, 11), metavar="0-10",
        help="每个任务的最大重试次数（默认: 3）",
    )

    args = parser.parse_args()

    # --setup 模式
    if args.setup:
        run_setup()
        return

    # 互斥检查
    if args.batch and args.prompt:
        parser.error("--batch 和 --prompt 不能同时使用")
    if not args.batch and not args.prompt:
        parser.error("必须指定 --prompt（单图模式）或 --batch（批量模式），或使用 --setup 配置")

    # 解析 API Key
    api_key = resolve_api_key(args.api_key)

    if args.batch:
        # 批量模式
        batch_path = Path(args.batch)
        if not batch_path.exists():
            print(f"错误: 批量任务文件不存在: {batch_path}", file=sys.stderr)
            sys.exit(1)

        try:
            tasks = json.loads(batch_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as e:
            print(f"错误: 解析批量任务文件失败: {e}", file=sys.stderr)
            sys.exit(1)

        if not isinstance(tasks, list) or not tasks:
            print("错误: 批量任务文件必须是非空 JSON 数组", file=sys.stderr)
            sys.exit(1)

        for i, t in enumerate(tasks):
            if "prompt" not in t or "output" not in t:
                print(f"错误: 任务 #{i + 1} 缺少必填字段 prompt 或 output", file=sys.stderr)
                sys.exit(1)

        results = generate_batch(
            tasks=tasks,
            api_key=api_key,
            workers=args.workers,
            max_retries=args.retry,
        )

        # 输出汇总 JSON
        print("\n" + json.dumps(results, indent=2, ensure_ascii=False))

        if any(not r["success"] for r in results if r):
            sys.exit(1)
    else:
        # 单图模式
        generate(
            prompt=args.prompt,
            api_key=api_key,
            aspect_ratio=args.aspect_ratio,
            image_size=args.size,
            output_path=args.output,
            max_retries=args.retry,
        )


if __name__ == "__main__":
    main()
