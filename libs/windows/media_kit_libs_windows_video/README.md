# [package:media_kit_libs_windows_video](https://github.com/media-kit/media-kit)

Windows package providing video (& audio) native libraries for [`package:media_kit`](https://github.com/media-kit/media-kit).

**This fork vendors libmpv and ANGLE under `windows/vendor/`** so Windows builds do not download dependencies from the network.

Visit [media-kit/libmpv-win32-video-cmake](https://github.com/media-kit/libmpv-win32-video-cmake) for upstream build details.

## Offline setup (maintainers)

```powershell
.\scripts\download_vendor.ps1
```

Commit `windows/vendor/**/*.7z` (use Git LFS for large binaries). See [windows/vendor/README.md](./windows/vendor/README.md).

## License

Copyright © 2021 & onwards, Hitesh Kumar Saini <<saini123hitesh@gmail.com>>

This project & the work under this repository is governed by MIT license that can be found in the [LICENSE](./LICENSE) file.
