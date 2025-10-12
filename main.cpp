#include <QApplication>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QMessageBox>
#include <QUrl>
#include <QDebug>
#include "windowmanager.h"
#include "singleapplication.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setStyle("Fusion");
    
    /************** begin: 保证只能运行一个程序 *****************/
    // 创建单实例应用管理器
    const QString appId = QString::fromLatin1("clock_cpp_single_instance");
    SingleApplication singleApplication(appId);
    
    if (singleApplication.isRunning()) {
        // 已有实例在运行,激活已有窗口
        qDebug() << "检测到已运行的实例,正在激活现有窗口...";
        singleApplication.activateExistingInstance();
        return 0;
    }
    /************** end: 保证只能运行一个程序 *****************/

    // 创建 WindowManager 实例
    WindowManager windowManager;
    
    QQmlApplicationEngine engine;
    
    // 将 WindowManager 注册到 QML
    qmlRegisterSingletonInstance("WindowManagerModule", 1, 0, "WindowManager", &windowManager);
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [](const QUrl &) {
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.loadFromModule(QString::fromLatin1("Clock"), QString::fromLatin1("Main"));
    
    // 连接激活信号到窗口管理器
    QObject::connect(&singleApplication, &SingleApplication::instanceActivated,
                     &windowManager, &WindowManager::activateWindow);
    
    return app.exec();
}
