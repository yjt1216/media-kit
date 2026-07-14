# Offline vendor binaries (Windows video)

CMake copies archives from here into the app `build/windows/<arch>/` directory. **No network download** occurs during `flutter build windows` when these files are present.

## Layout

```text
vendor/
  common/
    ANGLE.7z              # shared by x64 and ARM64
    ANGLE/                # optional: pre-extracted (skips 7z)
  x86_64/
    mpv-dev-x86_64-20241021-git-0f78584.7z
    libmpv/               # optional: pre-extracted, include/ layout as after CMake extract
  aarch64/
    mpv-dev-aarch64-20241021-git-0f78584.7z
    libmpv/
```

## Populate (maintainers, once per upstream bump)

From the repository root or this package:

```powershell
.\libs\windows\media_kit_libs_windows_video\scripts\download_vendor.ps1
```

Then commit the `.7z` files (Git LFS recommended).

## MD5 checksums

| File | MD5 |
|------|-----|
| `common/ANGLE.7z` | `e866f13e8d552348058afaafe869b1ed` |
| `x86_64/mpv-dev-x86_64-20241021-git-0f78584.7z` | `6ecf18e85b093c3f7edb16f3ee6603f3` |
| `aarch64/mpv-dev-aarch64-20241021-git-0f78584.7z` | `5b507a35db13eee6cb7eb21e8be7c83d` |
