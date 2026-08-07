// Bar.qml
import Quickshell
import QtQuick
import "widgets"
import "theme"
import "states"

Scope {
  // no more time object

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

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
        }

        VolumeWidget {
        }

        BrightnessWidget {
        }

        BatteryWidget {
        }

        ClockWidget {
          // no more time binding
        }

        NotificationBellWidget {
        }
      }

    }
  }
}
