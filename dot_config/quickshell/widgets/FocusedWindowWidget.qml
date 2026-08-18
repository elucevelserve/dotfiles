import QtQuick
import "../theme"
import "../states"
import "../services"

Item {
  implicitWidth: titleText.implicitWidth
  implicitHeight: titleText.implicitHeight

  Text {
    id: titleText
    color: Theme.textPrimary
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    text: FocusedWindowState.focusedTitle
    elide: Text.ElideRight
    width: Math.min(500, implicitWidth)
  }
}