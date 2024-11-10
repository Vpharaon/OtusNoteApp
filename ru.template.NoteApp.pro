TARGET = ru.template.NoteApp

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/main.cpp \

HEADERS += \

DISTFILES += \
    qml/assets/AppDatabase.js \
    rpm/ru.template.NoteApp.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.NoteApp.ts \
    translations/ru.template.NoteApp-ru.ts \
