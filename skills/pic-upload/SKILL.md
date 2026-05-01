---
name: pic-upload
description: >
      Upload local image files to image hosting via PicGo Server and return permanent CDN URLs.
      Use when needing to upload screenshots, generated images, or any local image file to get
      a permanent image hosting link. Triggers on upload image, picgo upload, picUpload, or
      whenever a permanent image URL is needed from a local file.
---

# pic-upload - PicGo 图床上传

Upload local images to PicGo image hosting via the PicGo Server API.

## Pre-check (Required)

Before uploading, verify PicGo Server is running:

```bash
lsof -i :36677 | grep LISTEN
```

**If the server is NOT running:**

PicGo 图床服务未启动。请确认已完成以下准备：

1. 安装 PicGo 客户端：https://molunerfinn.com/PicGo/
2. 在 PicGo 中配置图床（推荐 GitHub + jsDelivr）
3. 在 PicGo 设置中开启 Server 服务（默认端口 36677）

详细安装和配置教程请参考：

https://mp.weixin.qq.com/s/ggkbdAo5zt6aEBgBGuU0EA

配置完成后重新使用本 skill。

## Workflow

1. Run pre-check to verify PicGo Server is running
2. Verify the local image file exists
3. Upload: `curl -s -X POST http://localhost:36677/upload -F "files=@<file_path>"`
4. Parse JSON response, extract URL from `result[0]`
5. Return the CDN URL for use in markdown or other output

## API Details

**Single upload:**
```bash
curl -s -X POST http://localhost:36677/upload -F "files=@/path/to/image.png"
```

**Batch upload:**
```bash
curl -s -X POST http://localhost:36677/upload -F "files=@/path/to/img1.png" -F "files=@/path/to/img2.jpg"
```

**Response (success):**
```json
{"success": true, "result": ["https://cdn.jsdelivr.net/gh/user/repo/images/image.png"]}
```

**Response (failure):**
```json
{"success": false, "result": [], "message": "error details"}
```

## Error Handling

- Server unreachable: show the Pre-check instructions above
- Upload fails: report the `message` field from response
- Default port: 36677

## Notes

- Field name must be `files` (not `list[]` or `file`)
- Supported formats: PNG, JPG, JPEG, GIF, WEBP, SVG, BMP
