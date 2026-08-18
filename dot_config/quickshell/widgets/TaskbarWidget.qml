import QtQuick
import Quickshell
import Quickshell.Widgets
import "."
import "../theme"
import "../states"
import "../services"

Item {
  id: root
  required property var panelWindow

  implicitHeight: 16

  Component {
    id: markerDelegate
    Item {
      id: block
      required property var modelData
      clip: true

      readonly property var workspace: NiriService.workspaces.find(w => w.id === modelData.workspace_id)
      readonly property bool isNonActiveActiveWindow:
        workspace
        && workspace.id !== NiriService.activeWorkspaceId
        && workspace.active_window_id === modelData.id

      width: 20
      height: 16

      Rectangle {
        anchors.fill: parent
        visible: block.modelData.is_focused || block.isNonActiveActiveWindow
        color: "transparent"
        border.color: block.modelData.is_focused
          ? Theme.taskbarMarker
          : Qt.rgba(Theme.taskbarMarker.r, Theme.taskbarMarker.g, Theme.taskbarMarker.b, 0.35)
        border.width: 1
      }

      IconImage {
        anchors.fill: parent
        implicitSize: 20
        source: {
          AppIconService.revision // re-evaluate when desktop entries load
          return AppIconService.resolveIconPath(block.modelData.app_id, block.modelData.pid)
        }
        asynchronous: true
        mipmap: true
      }

      MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: NiriActions.focusWindow(block.modelData.id)
      }

      Tooltip {
        id: blockTip
        text: block.modelData.title || block.modelData.app_id || ""
        anchorItem: block
        panelWindow: root.panelWindow
        barAtTop: false
        visible: hover.containsMouse || blockTip.tipArea.containsMouse
      }
    }
  }

  Item {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    visible: !TaskbarViewState.taskbarCompact

    Row {
      anchors.centerIn: parent
      spacing: 0

      Repeater {
        model: TaskbarViewState.groupedWindows
        delegate: Row {
          id: groupRow
          required property int index
          required property var modelData
          spacing: 0

          Item {
            visible: groupRow.index > 0
            width: 8
            height: 16
            Rectangle {
              anchors.centerIn: parent
              width: 2
              height: 12
              radius: 1
              color: Qt.rgba(Theme.taskbarMarker.r, Theme.taskbarMarker.g, Theme.taskbarMarker.b, 0.35)
            }
            Rectangle {
              anchors.centerIn: parent
              width: 4
              height: 4
              radius: width / 2
              color: Qt.rgba(Theme.taskbarMarker.r, Theme.taskbarMarker.g, Theme.taskbarMarker.b, 0.35)
            }
          }

          Row {
            spacing: 3
            Repeater {
              model: groupRow.modelData.windows
              delegate: markerDelegate
            }
          }
        }
      }
    }
  }

  Item {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    visible: TaskbarViewState.taskbarCompact

    Row {
      anchors.centerIn: parent
      spacing: 0

      Repeater {
        model: NiriService.workspaces.slice().sort((a, b) => a.idx - b.idx)
        delegate: Row {
          id: slot
          required property int index
          required property var modelData
          spacing: 0

          Item {
            visible: slot.index > 0
            width: 8
            height: 16
          }

          Item {
            id: button
            visible: slot.modelData.id !== NiriService.activeWorkspaceId
            width: 12
            height: 16
            Rectangle {
              width: 12
              height: 8
              anchors.verticalCenter: parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter
              radius: 2
              color: Qt.rgba(Theme.taskbarMarker.r, Theme.taskbarMarker.g, Theme.taskbarMarker.b, 0.35)
            }
            MouseArea {
              id: bhover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: NiriActions.focusWorkspace(slot.modelData.idx)
            }
            Tooltip {
              id: buttonTip
              text: slot.modelData.name || ("Workspace " + slot.modelData.idx)
              anchorItem: button
              panelWindow: root.panelWindow
              barAtTop: false
              visible: bhover.containsMouse || buttonTip.tipArea.containsMouse
            }
          }

          Row {
            visible: slot.modelData.id === NiriService.activeWorkspaceId
            spacing: 3
            Repeater {
              model: slot.modelData.id === NiriService.activeWorkspaceId ? TaskbarViewState.activeWorkspaceWindows : []
              delegate: markerDelegate
            }
          }
        }
      }
    }
  }
}
