// BrightnessWidget.qml
// need inotifywait and brightnessctl
import QtQuick
import "../theme"
import "../states"
import "../services"

Item {
  id: root
  required property var panelWindow

  visible: BrightnessService.hasBacklight

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
      ControlCenterState.openAt("display", root)
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