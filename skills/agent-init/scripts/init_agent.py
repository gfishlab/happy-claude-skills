#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
SKILL_DIR = SCRIPT_DIR.parent
TEMPLATES_DIR = SKILL_DIR / "templates"

AGENT_CONFIG = {
    "codex": {
        "entry": "AGENTS.md",
        "runtime": ".codex",
        "entry_template": TEMPLATES_DIR / "codex" / "entry.md",
        "entry_append_template": TEMPLATES_DIR / "codex" / "entry-append.md",
    },
    "claude-code": {
        "entry": "CLAUDE.md",
        "runtime": ".claude",
        "entry_template": TEMPLATES_DIR / "claude-code" / "entry.md",
        "entry_append_template": TEMPLATES_DIR / "claude-code" / "entry-append.md",
    },
}

RUNTIME_TEMPLATE_DIRS = {
    "rules": TEMPLATES_DIR / "common" / "rules",
    "hooks": TEMPLATES_DIR / "common" / "hooks",
    "memory": TEMPLATES_DIR / "common" / "memory",
    "subagents": TEMPLATES_DIR / "common" / "subagents",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="初始化 Agent 项目协作骨架")
    parser.add_argument("--agent", required=True, choices=["codex", "claude-code"])
    parser.add_argument("--root", required=True, help="项目根目录")
    return parser.parse_args()


def ensure_dir(path: Path) -> bool:
    if path.exists():
        return False
    path.mkdir(parents=True, exist_ok=True)
    return True


def ensure_file(path: Path, content: str) -> bool:
    if path.exists():
        return False
    path.write_text(content, encoding="utf-8")
    return True


def read_template(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def append_missing_block(path: Path, marker: str, block: str) -> bool:
    if not path.exists():
        return False

    current = path.read_text(encoding="utf-8")
    if marker in current:
        return False

    updated = current.rstrip() + "\n\n" + block.rstrip() + "\n"
    path.write_text(updated, encoding="utf-8")
    return True


def init_entry_file(root: Path, agent: str, created: list[str], reused: list[str]) -> None:
    config = AGENT_CONFIG[agent]
    entry_path = root / config["entry"]
    entry_content = read_template(config["entry_template"])

    if ensure_file(entry_path, entry_content):
        created.append(str(entry_path))
        return

    append_block = read_template(config["entry_append_template"])
    if append_missing_block(entry_path, "## Agent 工程运行约定", append_block):
        created.append(f"{entry_path} (extended)")
    else:
        reused.append(str(entry_path))


def init_runtime_dir(root: Path, agent: str, created: list[str], reused: list[str]) -> None:
    runtime_name = AGENT_CONFIG[agent]["runtime"]
    runtime_path = root / runtime_name

    if ensure_dir(runtime_path):
        created.append(str(runtime_path))
    else:
        reused.append(str(runtime_path))

    for category, template_dir in RUNTIME_TEMPLATE_DIRS.items():
        category_path = runtime_path / category
        if ensure_dir(category_path):
            created.append(str(category_path))
        else:
            reused.append(str(category_path))

        for template_path in sorted(template_dir.glob("*.md")):
            file_path = category_path / template_path.name
            content = read_template(template_path)
            if ensure_file(file_path, content):
                created.append(str(file_path))
            else:
                reused.append(str(file_path))


def print_summary(agent: str, root: Path, created: list[str], reused: list[str]) -> None:
    print(f"agent={agent}")
    print(f"root={root}")
    print("")
    print("reused:")
    for item in reused:
        print(f"- {item}")
    print("")
    print("created:")
    for item in created:
        print(f"- {item}")


def main() -> None:
    args = parse_args()
    root = Path(args.root).resolve()

    created: list[str] = []
    reused: list[str] = []

    init_entry_file(root, args.agent, created, reused)
    init_runtime_dir(root, args.agent, created, reused)

    print_summary(args.agent, root, created, reused)


if __name__ == "__main__":
    main()
