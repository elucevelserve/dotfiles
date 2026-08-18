// NotificationActionsBar.qml
// Renders a notification's actions[] as a row of buttons. Invokes the
// live NotificationAction.invoke() — signals the DBus sender.
import Quickshell
import QtQuick
import ".."
import "../components"
import "../services"
import "../theme"
import "../states"

Row {
  id: root
  property var notification: null
  spacing: 6

  readonly property var actions: {
    NotificationService.revision
    return notification
      ? NotificationService.getActions(String(notification.id))
      : []
  }

  function invoke(idx) {
    if (idx < 0 || idx >= actions.length) return
    if (!notification) return
    const raw = notification.actions && notification.actions[idx]
    if (raw && raw.invoke) raw.invoke()
  }

  Repeater {
    model: root.actions
    delegate: ActionButton {
      required property var modelData
      text: modelData ? (modelData.label || "") : ""
      visible: text.length > 0
      onClicked: root.invoke(index)
    }
  }
}