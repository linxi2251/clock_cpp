#!/bin/bash
# 安装桌面快捷方式

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DESKTOP_FILE="$SCRIPT_DIR/clock-xwayland.desktop"
LOCAL_APPS="$HOME/.local/share/applications"

echo "安装时钟应用桌面快捷方式..."

# 创建应用目录
mkdir -p "$LOCAL_APPS"

# 更新 desktop 文件中的路径
sed -i "s|/home/buf/Desktop/clock_cpp|$SCRIPT_DIR|g" "$DESKTOP_FILE"

# 复制 desktop 文件
cp "$DESKTOP_FILE" "$LOCAL_APPS/clock-xwayland.desktop"

# 更新桌面数据库
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$LOCAL_APPS"
fi

echo "✓ 安装完成!"
echo ""
echo "您现在可以:"
echo "  1. 在应用菜单中搜索 '模拟时钟' 启动"
echo "  2. 使用脚本启动: ./run_with_xwayland.sh"
echo "  3. 直接运行: QT_QPA_PLATFORM=xcb ./build/clock"
echo ""
echo "注意: 使用 XWayland 运行可以在 Wayland 环境下启用窗口置顶功能"
