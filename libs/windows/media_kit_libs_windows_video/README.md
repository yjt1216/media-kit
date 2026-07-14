# [package:media_kit_libs_windows_video](https://github.com/media-kit/media-kit)

Windows package providing video (& audio) native libraries for [`package:media_kit`](https://github.com/media-kit/media-kit).

**This fork vendors libmpv and ANGLE under `windows/vendor/`** so Windows builds do not download dependencies from the network.

Visit [media-kit/libmpv-win32-video-cmake](https://github.com/media-kit/libmpv-win32-video-cmake) for upstream build details.

## Offline setup (maintainers)

```powershell
.\scripts\download_vendor.ps1
```

Commit `windows/vendor/**/*.7z` (use Git LFS for large binaries). See [windows/vendor/README.md](./windows/vendor/README.md).

## Local 引入方案

克隆本 fork 并切换到含 `windows/vendor` 的分支（例如 `local`）后，Windows 构建无需再下载原生依赖。

### 方式 A：应用在本 monorepo 内（与 `media_kit_test` 相同）

在 fork 根 `pubspec.yaml` 的 `workspace` 中登记你的应用，并在应用 `pubspec.yaml` 中：

```yaml
resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  media_kit:
    path: ../media_kit
  media_kit_libs_video:
    path: ../libs/universal/media_kit_libs_video
  media_kit_video:
    path: ../media_kit_video
```

`media_kit_libs_windows_video` 会由 workspace 自动解析为本仓库内的离线包。

### 方式 B：独立 Flutter 工程（与 fork 并列目录）

`path` 依赖聚合包时，Pub 仍可能从 pub.dev 解析 `media_kit_libs_windows_video`，需 **override** 指向本 fork：

```yaml
dependencies:
  flutter:
    sdk: flutter
  media_kit:
    path: ../media-kit/media_kit
  media_kit_libs_video:
    path: ../media-kit/libs/universal/media_kit_libs_video
  media_kit_video:
    path: ../media-kit/media_kit_video

dependency_overrides:
  media_kit_libs_windows_video:
    path: ../media-kit/libs/windows/media_kit_libs_windows_video
```

路径 `../media-kit` 按你本机 clone 位置调整。也可用 `git` + `ref: local` + `path: libs/windows/media_kit_libs_windows_video` 代替 `path`。

## License

Copyright © 2021 & onwards, Hitesh Kumar Saini <<saini123hitesh@gmail.com>>

This project & the work under this repository is governed by MIT license that can be found in the [LICENSE](./LICENSE) file.
