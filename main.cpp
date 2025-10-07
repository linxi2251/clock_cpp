#include <QApplication>
#include <QCoreApplication>
#include <QLocalServer>
#include <QLocalSocket>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QMessageBox>
#include <QUrl>
#include "windowmanager.h"

// 单实例应用管理器
class SingleApplication {

public:
    explicit SingleApplication(const QString &appId);
    ~SingleApplication();

    bool isRunning();
private:
    QString m_appId;
    QLocalServer *m_localServer{nullptr};
};

SingleApplication::SingleApplication(const QString &appId)
    : m_appId(appId)
{
}

SingleApplication::~SingleApplication()
{
    if (m_localServer) {
        if (m_localServer->isListening()) {
            m_localServer->close();
        }
        delete m_localServer;
        m_localServer = nullptr;
    }

    QLocalServer::removeServer(m_appId);
}

bool SingleApplication::isRunning()
{
    QLocalSocket socket;
    socket.connectToServer(m_appId);

    if (socket.waitForConnected(500)) {
        socket.disconnectFromServer();
        return true;
    }

    if (m_localServer && m_localServer->isListening()) {
        return false;
    }

    if (!m_localServer) {
        m_localServer = new QLocalServer;
    }

    QLocalServer::removeServer(m_appId);

    if (!m_localServer->listen(m_appId)) {
        delete m_localServer;
        m_localServer = nullptr;
        QLocalServer::removeServer(m_appId);
        return true;
    }

    return false;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setStyle("Fusion");
    const QString appId = QString::fromLatin1("clock_cpp_single_instance");
    SingleApplication singleApplication(appId);
    if (singleApplication.isRunning()) {
        QMessageBox::warning(nullptr,
                             QObject::tr("应用正在运行"),
                             QObject::tr("另一个程序实例已在运行。"));
        return 0;
    }

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

    return app.exec();
}
