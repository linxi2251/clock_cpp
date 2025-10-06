pragma Singleton
import QtQuick
import QtQuick.Window

QtObject {
    id: dpUtil

    // --- 基准 DPI：Android 同款 140dpi ---
    readonly property real baseDpi: 140

    // --- 当前屏幕逻辑密度（像素/毫米） ---
    property real pixelDensity: Screen.pixelDensity

    // --- 实际缩放比例 ---
    readonly property real scale: pixelDensity * 25.4 / baseDpi

    // --- 转换函数 ---
    function dp(x) { return x * scale }
    function sp(x) { return x * scale } // 用于字体（可根据需要微调）

    // --- 调试输出 ---
    function logInfo() {
        console.log("[Dp] 当前屏幕:", Screen.name,
                    "pixelDensity:", pixelDensity.toFixed(2),
                    "→ scale:", scale.toFixed(2))
    }

    // --- 主动绑定屏幕（在 ApplicationWindow 初始化后调用） ---
    function bindToWindow(win) {
        if (!win) return

        function updateDensity() {
            if (win.screen) {
                dpUtil.pixelDensity = win.screen.pixelDensity
                dpUtil.logInfo()
            } else {
                console.warn("No valid screen yet, delaying pixelDensity update...")
                Qt.callLater(updateDensity)
            }
        }

        // 初始化
        updateDensity()

        // 屏幕切换时自动刷新（加延迟）
        win.screenChanged.connect(function(newScreen) {
            console.log("Screen changed:", newScreen ? newScreen.name : "undefined")

            // 延迟执行，确保新 screen 已经绑定
            Qt.callLater(function() {
                updateDensity()
            })
        })
    }


}
