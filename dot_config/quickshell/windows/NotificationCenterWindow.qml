import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../services"
import "../theme"
import "../states"
import "../components"

PopupWindow {
  id: root
  visible: NotificationState.centerVisible
  grabFocus: true
  implicitWidth: NotificationState.centerWidth
  implicitHeight: 560

  anchor.window: NotificationState.centerAnchorWindow
  anchor.rect.x: NotificationState.centerAnchorX
  anchor.rect.y: NotificationState.centerAnchorY

  // One-way sync: outside-click dismissal (popup_done) hides us, so reflect
  // that in state. The bell drives opening via NotificationState.openCenter().
  onVisibleChanged: {
    if (!visible) NotificationState.centerVisible = false
  }

  Shortcut {
    sequence: "Escape"
    onActivated: NotificationState.centerVisible = false
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.surface
    border.width: 1
    border.color: Theme.notificationBorder

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8

      Row {
        spacing: 12
        Layout.fillWidth: true

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
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 8

        // ScriptModel diffs by QObject identity (objectProp: "id") so
        // revisions update rows incrementally — scroll position survives.
        model: ScriptModel {
          objectProp: "id"
          values: NotificationState.items
        }

        delegate: NotificationItem {
          required property var modelData
          width: listView.width
          notification: modelData
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
