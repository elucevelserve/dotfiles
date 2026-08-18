CXXFLAGS := $(shell pkg-config --cflags Qt6Core Qt6Qml) -fPIC
LIBS     := $(shell pkg-config --libs Qt6Core Qt6Qml)
MOC      := /usr/lib/qt6/moc
OUT      := $(HOME)/.local/lib/qt6/qml/PidExe

all: $(OUT)/libpid-exe.so

install: all
	cp qmldir $(OUT)/

$(OUT)/libpid-exe.so: PidExe.cpp PidExe.h plugin.cpp moc_plugin.cpp moc_PidExe.cpp | $(OUT)
	$(CXX) $(CXXFLAGS) -shared -o $@ PidExe.cpp plugin.cpp moc_PidExe.cpp $(LIBS)

moc_plugin.cpp: plugin.cpp
	$(MOC) $< -o $@

moc_PidExe.cpp: PidExe.h
	$(MOC) $< -o $@

$(OUT):
	mkdir -p $@

clean:
	rm -f moc_plugin.cpp moc_PidExe.cpp $(OUT)/libpid-exe.so
