// BarWidget.qml
// Shared root for top-bar widgets: spans the full bar-row height, centers
// its content vertically, and provides the full-height click area. Content
// declared inside a BarWidget lands in the centered slot.
import QtQuick

Item {
  id: root

  property var panelWindow: null
  property bool interactive: true
  property int acceptedButtons: Qt.LeftButton

  signal clicked(var mouse)
  signal scrolled(real delta)

  default property alias content: contentSlot.data

  implicitWidth: contentSlot.childrenRect.width
  implicitHeight: parent.height

  Item {
    id: contentSlot
    anchors.verticalCenter: parent.verticalCenter
    width: childrenRect.width
    height: childrenRect.height
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.interactive
    visible: root.interactive
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: root.acceptedButtons

    onClicked: mouse => root.clicked(mouse)
    onWheel: wheel => {
      const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.pixelDelta.y
      if (delta !== 0) {
        root.scrolled(delta)
      }
    }
  }
}