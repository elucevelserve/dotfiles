// Bar.qml
import Quickshell
import QtQuick
import "widgets"
import "theme"
import "states"

Scope {

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: barPanel
      required property var modelData
      screen: modelData
      // Workaround for niri #3887: popups only get keyboard focus from a
      // focusable parent, so the bar is focusable while the CC is open
      // (needed for Esc to close it).
      focusable: ControlCenterState.visible

      color: Theme.surface

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: Theme.barHeight

      Row {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        spacing: 12

        ResourceUsageWidget {
        }
      }

      Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        FocusedWindowWidget {
        }
      }

      Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        spacing: 12

        ControlCenterWidget {
          panelWindow: barPanel
        }

        VolumeWidget {
          panelWindow: barPanel
        }

        BrightnessWidget {
          panelWindow: barPanel
        }

        BatteryWidget {
        }

        ClockWidget {
        }

        NotificationBellWidget {
        }
      }

    }
  }
}
