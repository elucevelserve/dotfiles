import QtQuick
import Quickshell
import "../theme"
import "../states"

Item {
  id: root
  required property var panelWindow
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
      ControlCenterState.openAt("display", root)
    }
  }
}
