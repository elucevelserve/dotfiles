// Time.qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property date date: clock.date

  signal tickSeconds
  signal tickMinutes

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
    onDateChanged: root.tickSeconds()
  }

  SystemClock {
    precision: SystemClock.Minutes
    onDateChanged: root.tickMinutes()
  }
}
