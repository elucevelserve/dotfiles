// BrightnessWidget.qml
// need inotifywait and brightnessctl
import QtQuick
import "../theme"
import "../states"
import "../services"

Item {
  implicitWidth: brightnessText.implicitWidth
  implicitHeight: brightnessText.implicitHeight

  Text {
    id: brightnessText
    color: Theme.textPrimary
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    textFormat: Text.RichText
    text: BrightnessService.brightnessPercent >= 0
      ? BrightnessService.brightnessPercent + "% " + Theme.iconSpan("&#xf185;")
      : "BRI N/A"
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton

    onClicked: {
      const pos = parent.mapToGlobal(parent.width, parent.height + Theme.popupGap)
      ControlCenterState.toggleOnTab("display", pos.x, pos.y)
    }

    onWheel: function(wheel) {
      const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.pixelDelta.y
      if (delta === 0) {
        return
      }

      BrightnessService.adjustBrightness(delta)
      wheel.accepted = true
    }
  }
}