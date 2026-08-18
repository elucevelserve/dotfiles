import Quickshell
import QtQuick
import "widgets"
import "theme"
import "states"
import "services"

Scope {
  Variants {
    model: Quickshell.screens
    PanelWindow {
      id: taskbarPanel
      required property var modelData
      screen: modelData

      color: Theme.surface

      anchors {
        left: true
        right: true
        bottom: true
      }

      implicitHeight: 16

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: TaskbarViewState.taskbarCompact = !TaskbarViewState.taskbarCompact
      }

      TaskbarWidget {
        panelWindow: taskbarPanel
        anchors.centerIn: parent
      }

      SystemTrayWidget {
        panelWindow: taskbarPanel
        barAtTop: false
        anchors {
          right: parent.right
          verticalCenter: parent.verticalCenter
          rightMargin: 4
        }
      }
    }
  }
}