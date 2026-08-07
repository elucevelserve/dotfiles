pragma Singleton
import Quickshell
import QtQuick

Singleton {
  property bool visible: false
  property int x: 0
  property int y: 0
  property string activeTab: "display"

  function toggleOnTab(tabKey, anchorX, anchorY) {
    if (visible && activeTab === tabKey) {
      visible = false
      return
    }
    activeTab = tabKey
    x = Math.round(anchorX - 320)
    y = Math.round(anchorY)
    visible = true
  }
}
