import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import ".."
import "../services"
import "../theme"
import "../states"
import "../components"

Window {
  id: root
  visible: NotificationState.centerVisible
  width: 420
  height: 560
  flags: Qt.Popup | Qt.FramelessWindowHint
  color: "transparent"

  onVisibleChanged: {
    if (visible) {
      x = Screen.width - root.width - Theme.windowMargin
      y = Theme.popupTopOffset
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.surface
    border.width: 1
    border.color: Theme.notificationBorder

    Column {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8

      Row {
        spacing: 12
        width: parent.width

        ActionText {
          label: "DND"
          active: NotificationState.dndEnabled
          onTriggered: NotificationState.setDndEnabled(!NotificationState.dndEnabled)
        }
        ActionText {
          label: "Clear"
          onTriggered: NotificationState.clearAll()
        }
        ActionText {
          label: "Close"
          onTriggered: NotificationState.centerVisible = false
        }
        Text {
          text: NotificationState.count + " notifications"
          color: Theme.textMuted
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      ListView {
        id: listView
        width: parent.width
        height: parent.height - 80
        clip: true
        spacing: 8
        model: NotificationState.lanes

        delegate: Column {
          width: listView.width
          spacing: 4

          Text {
            text: modelData.label
            color: Theme.textMuted
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }

          Repeater {
            model: modelData.items
            delegate: NotificationItem {
              width: listView.width
              notification: modelData
            }
          }
        }

        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            NotificationState.centerVisible = false
            event.accepted = true
          }
        }
      }
    }
  }

  component ActionText: Text {
    id: actionTextRoot
    property string label: ""
    property bool active: false
    signal triggered
    color: active ? Theme.accent : Theme.textMuted
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    anchors.verticalCenter: parent.verticalCenter
    text: label
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: actionTextRoot.triggered()
    }
  }
}
