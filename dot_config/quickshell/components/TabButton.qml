// TabButton.qml
// Bordered button with active-fill. For selecting one of N options
// (tab switches, mode selection). For action triggers, use ActionButton.
import Quickshell
import QtQuick
import ".."
import "../theme"

Rectangle {
  id: root
  property string text: ""
  property bool active: false
  signal triggered

  implicitWidth: 64
  implicitHeight: 24
  radius: Theme.borderRadius
  color: active ? Theme.accent : Theme.surface
  border.width: 1
  border.color: Theme.notificationBorder

  Text {
    anchors.centerIn: parent
    width: parent.width - 8
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignHCenter
    text: root.text
    color: Theme.textPrimary
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.triggered()
  }
}
