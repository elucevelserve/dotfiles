import QtQuick
import Quickshell
import "../theme"
import "../states"

Item {
  id: root
  implicitWidth: iconText.implicitWidth
  implicitHeight: parent.height

  Text {
    id: iconText
    anchors.verticalCenter: parent.verticalCenter
    color: Theme.textPrimary
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    textFormat: Text.RichText
    text: Theme.iconSpan("&#xf1de;")
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton
    onClicked: {
      const pos = root.mapToGlobal(root.width, root.height + Theme.popupGap)
      ControlCenterState.x = Math.round(pos.x - Theme.controlCenterWidth)
      ControlCenterState.y = Math.round(pos.y)
      ControlCenterState.visible = !ControlCenterState.visible
    }
  }
}
