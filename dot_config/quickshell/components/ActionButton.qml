// ActionButton.qml
// Bordered button with hover-darken. For action triggers (dismiss, mute, invoke).
// For selectable tab/mode buttons, use TabButton.
import Quickshell
import QtQuick
import ".."
import "../theme"

Rectangle {
  id: root
  property string text: ""
  property color textColor: Theme.textPrimary
  signal clicked

  implicitWidth: labelText.implicitWidth + 16
  implicitHeight: labelText.implicitHeight + 8
  radius: Theme.borderRadius
  color: ma.containsMouse ? Qt.darker(Theme.surface, 1.2) : Theme.surface
  border.width: 1
  border.color: Theme.notificationBorder

  Text {
    id: labelText
    anchors.centerIn: parent
    text: root.text
    color: root.textColor
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
  }

  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
