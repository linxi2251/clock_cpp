#!/bin/bash
# 使用 XWayland 运行时钟应用
# 这样可以在 Wayland 环境下使用 X11 的窗口置顶功能

echo "使用 XWayland 启动时钟应用..."
echo "这将启用完整的窗口置顶支持"

export QT_QPA_PLATFORM=xcb
./clock

