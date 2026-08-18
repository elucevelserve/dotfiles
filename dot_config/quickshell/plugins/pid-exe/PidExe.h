#pragma once

#include <QObject>

class PidExe : public QObject {
  Q_OBJECT
public:
  Q_INVOKABLE QString resolve(int pid) const;
};
