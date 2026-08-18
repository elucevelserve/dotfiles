pragma Singleton
import Quickshell
import QtQuick
import "../theme"

Singleton {
  property bool visible: false
  property var anchorWindow: null
  property int anchorX: 0
  property int anchorY: 0
  property string activeTab: "display"

  function openAt(tabKey, widget) {
    if (visible && activeTab === tabKey) {
      visible = false
      return
    }
    // ponytail: pairwise close is fine for 2 popup windows; a third
    // warrants a shared "current popup" discriminator state instead
    NotificationState.centerVisible = false
    activeTab = tabKey
    const win = widget.panelWindow
    const g = widget.mapToGlobal(widget.width, widget.height + Theme.popupGap)
    anchorWindow = win
    anchorX = Math.round(g.x - win.screen.x - Theme.controlCenterWidth)
    anchorY = Math.round(g.y - win.screen.y)
    visible = true
  }
}
