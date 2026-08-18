// TaskbarViewState.qml
pragma Singleton
import Quickshell
import QtQuick
import "../services"

Singleton {
  property bool taskbarCompact: false

  readonly property var groupedWindows: {
    if (NiriService.workspaces.length === 0) return []
    return NiriService.workspaces
      .map(ws => ({
        workspace: ws,
        windows: NiriService.allWindows
          .filter(w => w.workspace_id === ws.id)
          .sort((a, b) => {
            const ax = a.layout && a.layout.pos_in_scrolling_layout
              ? a.layout.pos_in_scrolling_layout[0] : 0
            const bx = b.layout && b.layout.pos_in_scrolling_layout
              ? b.layout.pos_in_scrolling_layout[0] : 0
            return ax - bx
          })
      }))
      .filter(g => g.windows.length > 0)
      .sort((a, b) => a.workspace.idx - b.workspace.idx)
  }

  readonly property var activeWorkspaceWindows: {
    if (NiriService.activeWorkspaceId < 0) return []
    return NiriService.allWindows
      .filter(w => w.workspace_id === NiriService.activeWorkspaceId)
      .sort((a, b) => {
        const ax = a.layout && a.layout.pos_in_scrolling_layout
          ? a.layout.pos_in_scrolling_layout[0] : 0
        const bx = b.layout && b.layout.pos_in_scrolling_layout
          ? b.layout.pos_in_scrolling_layout[0] : 0
        return ax - bx
      })
  }
}
