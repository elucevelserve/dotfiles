#include <QQmlEngine>
#include <qqmlextensionplugin.h>

#include "PidExe.h"

class PidExePlugin : public QQmlExtensionPlugin {
  Q_OBJECT
  Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlEngineExtensionInterface")

public:
  void registerTypes(const char *uri) override {
    qmlRegisterSingletonType<PidExe>(uri, 1, 0, "PidExe", [](QQmlEngine *, QJSEngine *) -> QObject * {
      return new PidExe;
    });
  }
};

#include "moc_plugin.cpp"
