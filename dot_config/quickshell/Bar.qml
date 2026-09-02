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
      // focusable parent, so the bar is focusable while the CC or the
      // notification center is open (needed for Esc to close them).
      focusable: ControlCenterState.visible || NotificationState.centerVisible

      color: Theme.surface

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: Theme.barHeight

      // Rows span the full bar height so widgets get full-height click areas.
      Row {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        spacing: 12

        ResourceUsageWidget {
        }
      }

      Row {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        FocusedWindowWidget {
        }
      }

      Row {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
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
          panelWindow: barPanel
        }
      }

    }
  }
}
