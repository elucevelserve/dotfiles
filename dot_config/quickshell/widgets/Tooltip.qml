import QtQuick
import Quickshell
import "../theme"
import "../states"

PopupWindow {
  id: root
  property string text: ""
  property Item anchorItem
  property var panelWindow
  property bool barAtTop: true
  property alias tipArea: tipArea

  grabFocus: false

  implicitWidth: tipText.implicitWidth + 16
  implicitHeight: tipText.implicitHeight + 10

  anchor.window: root.panelWindow
  anchor.rect.x: {
    const g = anchorItem.mapToGlobal(0, 0)
    const s = root.panelWindow.screen
    return g.x - (s?.x ?? 0) + (anchorItem.width - implicitWidth) / 2
  }
  anchor.rect.y: root.barAtTop ? root.panelWindow.height : -implicitHeight

  Rectangle {
    anchors.fill: parent
    color: Theme.surface
    border.width: 1
    border.color: Theme.notificationBorder
    radius: Theme.borderRadius

    Text {
      id: tipText
      anchors.centerIn: parent
      text: root.text
      color: Theme.textPrimary
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
    }
  }

  MouseArea {
    id: tipArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
  }
}
