import QtQuick
import QtQuick.Controls

Menu {
    id: control

    delegate: MenuItem {
        id: menuItem
        implicitWidth: 150
        implicitHeight: 30
        arrow: Canvas {
            id: canvas
            x: parent.width - width
            implicitWidth: 34
            implicitHeight: 30
            visible: menuItem.subMenu
            onPaint: {
                var ctx = getContext("2d");
                ctx.fillStyle = palette.highlight;
                ctx.moveTo(9, 9);
                ctx.lineTo(width - 9, height / 2);
                ctx.lineTo(9, height - 9);
                ctx.closePath();
                ctx.fill();
            }
        }

        indicator: Item {
            implicitWidth: 20
            implicitHeight: 30
            Rectangle {
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 4
                visible: menuItem.checkable
                border.color: palette.highlight
                color: palette.window
                Rectangle {
                    width: 12
                    height: 12
                    anchors.centerIn: parent
                    visible: menuItem.checked
                    color: palette.highlight
                    radius: 2
                }
            }
        }
        contentItem: Label {
            leftPadding: menuItem.checkable ? menuItem.indicator.width : 0
            text: menuItem.text
            font: menuItem.font
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: enabled ? palette.text : palette.disabled.text
        }
        background: Rectangle {
            implicitWidth: 150
            implicitHeight: 30
            color: menuItem.highlighted ? palette.highlight : "transparent"
        }
    }
    background: Rectangle {
        implicitWidth: 150
        implicitHeight: 30

        color: control.palette.base
        border.color: Fusion.outline(control.palette)

        Rectangle {
            z: -1
            x: 1
            y: 1
            width: parent.width
            height: parent.height
            color: control.palette.shadow
            opacity: 0.2
        }
    }
}
