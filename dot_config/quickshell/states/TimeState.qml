// TimeState.qml
pragma Singleton
import Quickshell
import QtQuick
import "../services"

Singleton {
  id: root

  readonly property date date: TimeService.date

  readonly property string widgetDateTime: {
    Qt.formatDateTime(date, "hh:mm d-MMM")
  }
  readonly property string widgetTime: {
    Qt.formatDateTime(date, "hh:mm")
  }
  readonly property string detailedDate: {
    Qt.formatDateTime(date, "dddd d, MMMM, yyyy")
  }
  readonly property string detailedTime: {
    Qt.formatDateTime(date, "hh:mm:ss")
  }

  function pad2(value) {
    return value < 10 ? " " + value : "" + value
  }

  function calendarMonthLabelFor(year, month) {
    return Qt.formatDateTime(new Date(year, month, 1), "MMMM yyyy")
  }

  function calendarGridRichFor(year, month) {
    const firstDay = new Date(year, month, 1)
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    const firstColumn = (firstDay.getDay() + 6) % 7

    const now = TimeService.date
    const isCurrentMonth = year === now.getFullYear() && month === now.getMonth()
    const today = now.getDate()

    let lines = ["Mo Tu We Th Fr Sa Su"]
    let week = []
    for (let i = 0; i < firstColumn; i++) week.push("  ")
    for (let day = 1; day <= daysInMonth; day++) {
      const label = root.pad2(day)
      if (isCurrentMonth && day === today) {
        week.push("<span style=\"background-color:#4a90e2;color:#ffffff;\">" + label + "</span>")
      } else {
        week.push(label)
      }
      if (week.length === 7) {
        lines.push(week.join(" "))
        week = []
      }
    }
    if (week.length > 0) {
      while (week.length < 7) week.push("  ")
      lines.push(week.join(" "))
    }
    return "<pre>" + lines.join("\n") + "</pre>"
  }
}
