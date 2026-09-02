import QtQuick
import "../theme"
import "../states"
import "../services"

BarWidget {
  id: root
  interactive: false

  Row {
    id: usageRow
    spacing: 12

    Text {
      color: Theme.textPrimary
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
      textFormat: Text.RichText
      text: ResourceUsageService.cpuUsage + " " + Theme.iconSpan("&#xf2db;")
    }

    Text {
      color: Theme.textPrimary
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
      textFormat: Text.RichText
      text: ResourceUsageService.memoryUsage + " " + Theme.iconSpan("&#xf538;")
    }

    Text {
      color: Theme.textPrimary
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
      textFormat: Text.RichText
      text: ResourceUsageService.diskUsage + " " + Theme.iconSpan("&#xf0a0;")
    }

    Text {
      color: Theme.textPrimary
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
      textFormat: Text.RichText
      text: ResourceUsageService.temperature + " " + Theme.iconSpan("&#xf2c9;")
    }
  }
}