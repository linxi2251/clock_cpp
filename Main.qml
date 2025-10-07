import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Qt.labs.platform as Platform
import "calendar.mjs" as Lunar
import Clock

ApplicationWindow {
    id: window
    visible: true
    title: qsTr("模拟时钟")
    color: "transparent"
    property bool stayOnTop: false
    flags: stayOnTop ? Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint : Qt.FramelessWindowHint

    // 绑定屏幕（重要）
    Component.onCompleted: Dp.bindToWindow(window)
    function dp (x) { return Dp.dp(x) }

    width: dp(500)
    height: width

    // 系统托盘图标
    Platform.SystemTrayIcon {
        id: systemTray
        visible: true
        tooltip: qsTr("模拟时钟")
        icon.source: "qrc:/resources/clock-circle.png"

        onActivated: function(reason) {
            if (reason === Platform.SystemTrayIcon.Trigger) {
                if (window.visible && window.active) {
                    window.hide()
                } else {
                    window.show()
                    window.raise()
                    window.requestActivate()
                }
            }
        }

        menu: Platform.Menu {
            Platform.MenuItem {
                text: qsTr("显示/隐藏")
                onTriggered: {
                    if (window.visible) {
                        window.hide()
                    } else {
                        window.show()
                        window.raise()
                        window.requestActivate()
                    }
                }
            }

            Platform.MenuSeparator {}

            Platform.MenuItem {
                text: window.stayOnTop ? qsTr("📌置顶") : qsTr("置顶")
                onTriggered: window.stayOnTop = !window.stayOnTop
            }

            Platform.MenuSeparator {}

            Platform.MenuItem {
                text: qsTr("退出")
                onTriggered: Qt.quit()
            }
        }
    }

    Text {
        text: "📌"
        anchors.right: parent.right
        anchors.top: window.top
        visible: window.stayOnTop
        font.pixelSize: dp(18)
        anchors.rightMargin: dp(4)
        anchors.topMargin: dp(4)
    }

    MMenu {
        id: contextMenu
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        Action {
            text: window.stayOnTop ? qsTr("📌置顶") : qsTr("置顶")
            onTriggered: window.stayOnTop = !window.stayOnTop
        }

        MenuSeparator {}

        Action {
            text: qsTr("退出")
            onTriggered: Qt.quit()
        }
    }

    Rectangle {
        id: clock
        anchors.fill: parent
        anchors.margins: dp(10)
        radius: width / 2
        color: "white"
        border.color: "#333"
        border.width: dp(10)
        antialiasing: true

        property real baseHourMarkHeight: 20
        property real baseHourMarkWidth: 8
        property real baseHourMarkTopMargin: 10

        // 使窗口可拖动
        MouseArea {
            anchors.fill: parent
            property point clickPos: Qt.point(0, 0)
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: (mouse) => {
                           if (mouse.button === Qt.RightButton) {
                               contextMenu.popup(mouse.scenePosition)
                               mouse.accepted = true
                               return
                           }
                           clickPos = Qt.point(mouse.x, mouse.y)
                       }

            onPositionChanged: (mouse) => {
                                   if (!(mouse.buttons & Qt.LeftButton))
                                   return
                                   var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                                   window.x += delta.x
                                   window.y += delta.y
                               }

            onDoubleClicked: Qt.quit()
        }

        // 60个刻度
        Repeater {
            model: 60
            Item {
                width: clock.width
                height: clock.height
                rotation: index * 6

                Rectangle {
                    property bool isHourMark: index % 5 === 0
                    width: dp(isHourMark ? clock.baseHourMarkWidth : clock.baseHourMarkWidth / 4)
                    height: dp(isHourMark ? clock.baseHourMarkHeight : clock.baseHourMarkHeight / 2)
                    color: isHourMark ? "#333" : "#999"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: dp(isHourMark ? clock.baseHourMarkTopMargin : clock.baseHourMarkTopMargin + 5)
                    antialiasing: true
                }
            }
        }

        // 时钟数字 1-12
        Repeater {
            model: 12
            Item {
                width: clock.width
                height: clock.height
                rotation: (index + 1) * 30

                Text {
                    text: index + 1
                    font.pixelSize: dp(24)
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: dp(35)
                    rotation: -(index + 1) * 30
                }
            }
        }

        // 日期和星期显示
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: dp(hourHand.rotation > 90 && hourHand.rotation < 270 ? -40 : 40)
            spacing: dp(2)
            z: 5

            Text {
                id: dateText
                text: ""
                font.pixelSize: clock.height/20
                font.bold: true
                color: "#333"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: weekText
                text: ""
                font.pixelSize: dateText.font.pixelSize * 0.8
                color: "#666"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // 中心圆点
        Rectangle {
            width: hourHand.width * 1.5
            height: width
            radius: width / 2
            color: "#d32f2f"
            anchors.centerIn: parent
            z: 10
            antialiasing: true
        }

        // 时针
        Rectangle {
            id: hourHand
            width: minuteHand.width * 2
            height: minuteHand.height * 0.7
            color: "#333"
            radius: width/2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -height / 2
            transformOrigin: Item.Bottom
            rotation: 0
            antialiasing: true
        }

        // 分针
        Rectangle {
            id: minuteHand
            width: secondHand.width * 1.5
            height: secondHand.height * 0.8
            color: "#555"
            radius: width/2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -height / 2
            transformOrigin: Item.Bottom
            rotation: 0
            antialiasing: true
        }

        // 秒针
        Rectangle {
            id: secondHand
            width: dp(clock.baseHourMarkWidth / 2)
            height: clock.height/2 * 0.9
            color: "#d32f2f"
            radius: width/2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -height / 2
            transformOrigin: Item.Bottom
            rotation: 0
            antialiasing: true
        }
        // /** 公历年月日转农历数据 返回json */
        // calendar.solar2lunar(1987,11,01);
        // /** 农历年月日转公历年月日 */
        // calendar.lunar2solar(1987,9,10);
        // /**调用以上方法后返回类似如下object（json）具体以上就不需要解释了吧！*/
        // /** c开头的是公历各属性值 l开头的自然就是农历咯 gz开头的就是天干地支纪年的数据啦~ */
        // {
        //     Animal: "兔",
        //     IDayCn: "初十",
        //     IMonthCn: "九月",
        //     Term: null,
        //     astro: "天蝎座",
        //     cDay: 1,
        //     cMonth: 11,
        //     cYear: 1987,
        //     gzDay: "甲寅",
        //     gzMonth: "庚戌",
        //     gzYear: "丁卯",
        //     isLeap: false,
        //     isTerm: false,
        //     isToday: false,
        //     lDay: 10,
        //     lMonth: 9,
        //     lYear: 1987,
        //     nWeek: 7,
        //     ncWeek: "星期日"
        // }
        // 定时器更新时间
        Timer {
            id: timer
            interval: 16
            running: true
            repeat: true
            triggeredOnStart: true
            property int _currentDay: -1

            onTriggered: {
                var date = new Date()
                var hours = date.getHours()
                var minutes = date.getMinutes()
                var seconds = date.getSeconds()
                secondHand.rotation = seconds * 6
                minuteHand.rotation = minutes * 6 + seconds * 0.1
                hourHand.rotation = (hours % 12) * 30 + minutes * 0.5
                var year = date.getFullYear()
                var month = date.getMonth() + 1
                var day = date.getDate()
                if (_currentDay != day) {
                    clock.updateLunar(date)
                    _currentDay = day
                }
            }
        }

        function updateLunar(date) {
            var y = date.getFullYear();
            var m = date.getMonth() + 1;
            var d = date.getDate();
            var res = Lunar.calendar.solar2lunar(y, m, d);

            dateText.text = y + "年" + m + "月" + d + "日";
            console.log(dateText.text)
            var weekInfo = res.ncWeek + "  " + res.IMonthCn + res.IDayCn;
            if (res.lunarFestival)      weekInfo += "「" + res.lunarFestival + "」";
            else if (res.Term)          weekInfo += "「" + res.Term + "」";
            weekText.text = weekInfo;
        }
    }
}
