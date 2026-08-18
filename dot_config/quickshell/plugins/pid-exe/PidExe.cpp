#include "PidExe.h"

#include <QFile>

QString PidExe::resolve(int pid) const {
  if (pid <= 0) return "";
  return QFile::symLinkTarget("/proc/" + QString::number(pid) + "/exe");
}
