// NotificationReplyField.qml
// Inline reply TextField for notification actions of type "input".
import Quickshell
import QtQuick
import QtQuick.Controls
import "../theme"
import "../states"

Item {
  id: root
  property alias placeholderText: field.placeholderText
  signal send(string value)

  implicitHeight: field.implicitHeight

  TextField {
    id: field
    anchors.fill: parent
    placeholderText: "Reply..."
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    color: Theme.textPrimary
    background: Rectangle {
      color: Theme.surface
      border.color: Theme.notificationBorder
      border.width: 1
      radius: 3
    }
    Keys.onReturnPressed: root.send(text)
    Keys.onEnterPressed: root.send(text)
  }
}
