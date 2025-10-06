import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Qt.labs.platform as Platform
import Clock

ApplicationWindow {
  id: window
  width: 310
  height: 310
  visible: true
  title: qsTr("模拟时钟")
  color: "transparent"
  property bool stayOnTop: false
  flags: stayOnTop ? Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint : Qt.FramelessWindowHint

  Image {
    source: "qrc:/resources/clock-circle.png"
    anchors.fill: parent
  }

  // 系统托盘图标
  Platform.SystemTrayIcon {
    id: systemTray
    visible: true
    tooltip: qsTr("模拟时钟")
    icon.source: "qrc:/resources/clock-circle.png"

    onActivated: function(reason) {
      // 当点击托盘图标时
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
      id: quitAction
      text: qsTr("退出")
      onTriggered: Qt.quit()
    }
  }

  Rectangle {
    id: clock
    width: 300
    height: 300
    anchors.centerIn: parent
    radius: width / 2
    color: "white"
    border.color: "#333"
    border.width: 4

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

      onDoubleClicked: {
        Qt.quit()
      }
    }

    // 60个刻度(包含时刻度和分刻度)
    Repeater {
      model: 60
      Item {
        width: clock.width
        height: clock.height
        rotation: index * 6

        Rectangle {
          property bool isHourMark: index % 5 === 0
          width: isHourMark ? 4 : 1.5  // 时刻度更粗
          height: isHourMark ? 20 : 10  // 时刻度更长
          color: isHourMark ? "#333" : "#999"  // 时刻度更深
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: isHourMark ? 10 : 15
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
          font.pixelSize: 24
          font.bold: true
          color: "#333"
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: 35
          rotation: -(index + 1) * 30  // 反向旋转文字,保持正立
        }
      }
    }

    // 日期和星期显示
    Column {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: 40
      spacing: 2
      z: 5

      Text {
        id: dateText
        text: ""
        font.pixelSize: 13
        font.bold: true
        color: "#333"
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: weekText
        text: ""
        font.pixelSize: 11
        color: "#666"
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }

    // 中心圆点
    Rectangle {
      width: 15
      height: 15
      radius: width / 2
      color: "#d32f2f"
      anchors.centerIn: parent
      z: 10
    }

    // 时针
    Rectangle {
      id: hourHand
      width: 6
      height: 70
      color: "#333"
      radius: 3
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -height / 2 + 3
      transformOrigin: Item.Bottom

      rotation: 0
    }

    // 分针
    Rectangle {
      id: minuteHand
      width: 4
      height: 100
      color: "#555"
      radius: 2
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -height / 2 + 2
      transformOrigin: Item.Bottom

      rotation: 0
    }

    // 秒针
    Rectangle {
      id: secondHand
      width: 2
      height: 110
      color: "#d32f2f"
      radius: 1
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -height / 2 + 1
      transformOrigin: Item.Bottom

      rotation: 0
    }

    // 定时器更新时间
    Timer {
      interval: 1000
      running: true
      repeat: true
      triggeredOnStart: true

      onTriggered: {
        var date = new Date()
        var hours = date.getHours()
        var minutes = date.getMinutes()
        var seconds = date.getSeconds()

        // 秒针:每秒转6度
        secondHand.rotation = seconds * 6

        // 分针:每分钟转6度,加上秒数的影响
        minuteHand.rotation = minutes * 6 + seconds * 0.1

        // 时针:每小时转30度,加上分钟的影响
        hourHand.rotation = (hours % 12) * 30 + minutes * 0.5

        // 更新日期和星期
        var year = date.getFullYear()
        var month = date.getMonth() + 1
        var day = date.getDate()
        var weekDays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        var weekDay = weekDays[date.getDay()]

        dateText.text = year + "年" + month + "月" + day + "日"
        weekText.text = weekDay
      }
    }
  }
}
