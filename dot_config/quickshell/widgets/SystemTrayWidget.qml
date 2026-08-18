import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../theme"
import "../states"
import "."

Item {
  id: root
  implicitWidth: trayRow.implicitWidth
  implicitHeight: trayRow.implicitHeight

  required property var panelWindow
  property bool barAtTop: true

  readonly property var trayItems: SystemTray.items?.values ?? []

  Row {
    id: trayRow
    spacing: 6

    Repeater {
      model: root.trayItems

      delegate: Item {
        id: trayIcon
        required property var modelData
        readonly property var itemData: modelData

        visible: itemData.status !== Status.Passive
        implicitWidth: 16
        implicitHeight: 16

        IconImage {
          anchors.fill: parent
          implicitSize: 16
          source: itemData.icon || ""
          asynchronous: true
          mipmap: true
        }

        Rectangle {
          width: 6; height: 6; radius: 3
          color: Theme.accent
          anchors.right: parent.right; anchors.top: parent.top
          anchors.rightMargin: -2; anchors.topMargin: -2
          visible: itemData.status === Status.NeedsAttention
        }

        MouseArea {
          id: hoverArea
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true

          onClicked: function(mouse) {
            const openMenu = itemData.onlyMenu
                          || (mouse.button === Qt.RightButton && itemData.hasMenu)
            if (openMenu) {
              menuAnchor.open()
            } else if (mouse.button === Qt.LeftButton) {
              itemData.activate()
            } else {
              itemData.secondaryActivate()
            }
          }

          onWheel: function(wheel) {
            const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.pixelDelta.y
            if (delta === 0) {
              return
            }
            itemData.scroll(delta, false)
            wheel.accepted = true
          }
        }

        Tooltip {
          id: trayTip
          text: itemData.tooltipTitle || itemData.tooltipDescription || itemData.title || ""
          anchorItem: trayIcon
          panelWindow: root.panelWindow
          barAtTop: root.barAtTop
          visible: hoverArea.containsMouse || trayTip.tipArea.containsMouse
        }

        QsMenuAnchor {
          id: menuAnchor
          menu: itemData.menu
          anchor.window: root.panelWindow
          anchor.rect.x: {
            const g = hoverArea.mapToGlobal(0, 0)
            const s = root.panelWindow.screen
            return g.x - (s?.x ?? 0)
          }
          anchor.rect.y: root.barAtTop ? root.panelWindow.height : -200
        }
      }
    }
  }
}
