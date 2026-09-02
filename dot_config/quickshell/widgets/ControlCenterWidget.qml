import QtQuick
import Quickshell
import "../theme"
import "../states"

BarWidget {
  id: root

  onClicked: ControlCenterState.openAt("display", root)

  Text {
    id: iconText
    color: Theme.textPrimary
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    textFormat: Text.RichText
    text: Theme.iconSpan("&#xf1de;")
  }
}