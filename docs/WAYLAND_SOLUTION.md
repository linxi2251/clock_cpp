# Wayland 环境下窗口置顶解决方案

## 问题说明

在 Wayland 环境下,出于安全考虑,应用程序无法直接设置窗口置顶。这是 Wayland 协议的设计限制。

## 解决方案

### 方案 1: 使用 XWayland (推荐,最简单)

运行脚本以使用 XWayland 启动应用:

```bash
./run_with_xwayland.sh
```

或者手动指定:

```bash
QT_QPA_PLATFORM=xcb ./build/clock
```

这样应用会通过 XWayland 运行,可以使用完整的 X11 窗口管理功能,包括置顶。

### 方案 2: 配置 KDE 窗口规则

在 KDE Plasma 桌面环境中:

1. 打开 **系统设置** (System Settings)
2. 进入 **窗口管理** → **窗口规则** (Window Management → Window Rules)
3. 点击 **新建** 创建新规则
4. 在 **窗口匹配** 标签:
   - **窗口标题**: 选择 "完全匹配" 并输入 "模拟时钟"
   - 或 **窗口类 (class)**: 选择 "完全匹配" 并输入 "clock"
5. 在 **排列与特殊窗口设置** 标签:
   - 找到 **保持在最上层** (Keep above)
   - 勾选启用并选择 **是,初始设置** 或 **强制**
6. 点击 **应用** 保存规则

之后启动应用时,KWin 会自动将其置顶。

### 方案 3: 使用 KWin 脚本 (高级)

创建 KWin 脚本来自动处理窗口置顶请求:

1. 创建脚本目录:
   ```bash
   mkdir -p ~/.local/share/kwin/scripts/keepabove
   ```

2. 创建脚本文件 `~/.local/share/kwin/scripts/keepabove/contents/code/main.js`:
   ```javascript
   workspace.clientAdded.connect(function(client) {
       if (client.caption.includes("模拟时钟") || client.resourceClass == "clock") {
           client.keepAbove = true;
       }
   });
   ```

3. 创建元数据文件 `~/.local/share/kwin/scripts/keepabove/metadata.desktop`:
   ```ini
   [Desktop Entry]
   Name=Keep Clock Above
   Comment=Automatically keep clock application above other windows
   X-KDE-PluginInfo-Author=User
   X-KDE-PluginInfo-Email=user@example.com
   X-KDE-PluginInfo-Name=keepabove
   X-KDE-PluginInfo-Version=1.0
   X-KDE-PluginInfo-Category=Scripts
   X-KDE-ServiceTypes=KWin/Script
   X-Plasma-API=javascript
   X-Plasma-MainScript=code/main.js
   ```

4. 在系统设置中启用脚本:
   - **系统设置** → **窗口管理** → **KWin 脚本**
   - 找到并勾选 "Keep Clock Above"

### 方案 4: 临时切换到 X11 会话

在登录屏幕选择 "Plasma (X11)" 会话而不是 "Plasma (Wayland)"。

## 检测当前环境

运行以下命令查看当前使用的显示服务器:

```bash
echo $XDG_SESSION_TYPE
```

- 如果输出 `wayland`,说明运行在 Wayland 下
- 如果输出 `x11`,说明运行在 X11 下

## 代码实现说明

C++ 代码已经实现了:
- ✅ 自动检测运行环境 (X11/Wayland)
- ✅ 在 X11 下使用原生 X11 API 设置窗口置顶
- ✅ 在 Wayland 下提供警告和解决方案提示
- ✅ 提供 XWayland 运行脚本

## 推荐做法

**最简单**: 使用 `run_with_xwayland.sh` 脚本启动应用

**最优雅**: 配置 KDE 窗口规则 (方案 2)

**最灵活**: 如果需要经常切换置顶状态,使用 XWayland (方案 1)
