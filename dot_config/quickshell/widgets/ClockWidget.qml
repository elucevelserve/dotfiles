// ClockWidget.qml
import QtQuick
import Quickshell
import QtQuick.Window
import "../theme"
import "../states"
import "../services"

Item {
  id: root
  implicitWidth: clockText.implicitWidth
  implicitHeight: clockText.implicitHeight
  property bool showDateTime: true
  property int viewYear: TimeService.date.getFullYear()
  property int viewMonth: TimeService.date.getMonth()

  function resetCalendarToToday() {
    viewYear = TimeService.date.getFullYear()
    viewMonth = TimeService.date.getMonth()
  }

  function shiftCalendarMonth(delta) {
    const monthIndex = viewMonth + delta
    viewYear = viewYear + Math.floor(monthIndex / 12)
    viewMonth = ((monthIndex % 12) + 12) % 12
  }

  function positionDetailsWindow() {
    const position = root.mapToGlobal(0, root.height + Theme.popupGap)
    detailsWindow.x = Math.round(position.x + (root.width - detailsWindow.width) / 2)
    detailsWindow.y = Math.round(position.y)
  }

  Text {
    id: clockText
    text: root.showDateTime ? TimeState.widgetDateTime : TimeState.widgetTime
    color: Theme.textPrimary
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    font.bold: true
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: function(mouse) {
      if (mouse.button === Qt.LeftButton) {
        if (!detailsWindow.visible) {
          root.resetCalendarToToday()
          root.positionDetailsWindow()
        }
        detailsWindow.visible = !detailsWindow.visible
      }
      if (mouse.button === Qt.RightButton) {
        root.showDateTime = !root.showDateTime
      }
    }
  }

  Window {
    id: detailsWindow
    color: Theme.surface
    visible: false
    width: 260
    height: 250
    flags: Qt.Popup | Qt.FramelessWindowHint

    Column {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 6

      Text {
        text: TimeState.detailedTime
        color: Theme.textPrimary
        font.family: Theme.fontMainFamily
        font.pixelSize: Theme.fontSize
      }

      Text {
        text: TimeState.detailedDate
        color: Theme.textPrimary
        font.family: Theme.fontMainFamily
        font.pixelSize: Theme.fontSize
      }

      Text {
        text: TimeState.calendarMonthLabelFor(root.viewYear, root.viewMonth)
        color: Theme.textPrimary
        font.family: Theme.fontMainFamily
        font.pixelSize: Theme.fontSize
      }

      Row {
        spacing: 8

        Text {
          text: "<"
          color: Theme.textPrimary
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize

          MouseArea {
            anchors.fill: parent
            onClicked: root.shiftCalendarMonth(-1)
          }
        }

        Text {
          text: "Today"
          color: Theme.textPrimary
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize

          MouseArea {
            anchors.fill: parent
            onClicked: root.resetCalendarToToday()
          }
        }

        Text {
          text: ">"
          color: Theme.textPrimary
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize

          MouseArea {
            anchors.fill: parent
            onClicked: root.shiftCalendarMonth(1)
          }
        }
      }

      Text {
        text: TimeState.calendarGridRichFor(root.viewYear, root.viewMonth)
        textFormat: Text.RichText
        font.family: Theme.fontMainFamily
        font.pixelSize: Theme.fontSize
        color: Theme.textPrimary
      }
    }
  }
}