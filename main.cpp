#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "gamecontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<GameController>("Game", 1, 0, "GameController");

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("SangNT26_GameProject", "Main");

    return app.exec();
}
