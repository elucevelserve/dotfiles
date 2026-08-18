// NotificationActionsBar.qml
// Renders a notification's actions[] as a row of buttons. Optional
// inline reply field for action.type === "input". Invokes the live
// Notification.invokeAction(actionId, value) — signals the DBus sender.
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

  function invoke(idx, value) {
    if (idx < 0 || idx >= actions.length) return
    if (!notification) return
    const a = actions[idx]
    if (!a || !a.id) return
    notification.invokeAction(a.id, value)
  }

  Repeater {
    model: root.actions
    delegate: Item {
      id: delegateItem
      readonly property bool hasContent: inputField.visible || (actionData && actionData.label && actionData.label.length > 0)
      width: hasContent ? (inputField.visible ? root.width : actionButton.implicitWidth) : 0
      height: Math.max(actionButton.implicitHeight, inputField.implicitHeight)
      visible: hasContent

      property var actionData: modelData

      ActionButton {
        id: actionButton
        text: delegateItem.actionData ? (delegateItem.actionData.label || "") : ""
        visible: !inputField.visible && text.length > 0
        onClicked: root.invoke(index, null)
      }

      NotificationReplyField {
        id: inputField
        anchors.fill: parent
        visible: actionData && actionData.type === "input"
        placeholderText: actionData ? (actionData.placeholder || "Reply...") : ""
        onSend: function(value) { root.invoke(index, value) }
      }
    }
  }
}
