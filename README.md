clock cpp版本
Python版本：https://github.com/linxi2251/clock_app

## 窗口置顶功能说明

### X11 环境
在 X11 环境下,窗口置顶功能可以正常使用。应用程序会自动使用 X11 API 来设置窗口置顶。

### Wayland 环境
由于 Wayland 的安全限制,应用程序无法直接设置窗口置顶。您有以下解决方案:

**方案 1: 使用 XWayland (推荐)**
```bash
./run_with_xwayland.sh
```
或
```bash
QT_QPA_PLATFORM=xcb ./build/clock
```

**方案 2: 配置 KDE 窗口规则**
在 KDE 系统设置 → 窗口管理 → 窗口规则 中为此应用创建规则,强制设置"保持在最上层"。

详细说明请查看 [WAYLAND_SOLUTION.md](WAYLAND_SOLUTION.md)

## 构建和运行

```bash
# 配置
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release

# 编译
cmake --build build -j$(nproc)

# 运行 (Wayland 环境推荐使用 XWayland)
./run_with_xwayland.sh

# 或直接运行 (X11 环境)
./build/clock
```