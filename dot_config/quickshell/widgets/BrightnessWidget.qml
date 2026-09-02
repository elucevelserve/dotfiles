// BrightnessWidget.qml
// need inotifywait and brightnessctl
import QtQuick
import "../theme"
import "../states"
import "../services"

BarWidget {
  id: root

  visible: BrightnessService.hasBacklight

  onClicked: ControlCenterState.openAt("display", root)
  onScrolled: delta => BrightnessService.adjustBrightness(delta)

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
}