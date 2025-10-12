#include "singleapplication.h"
#include <QDebug>

SingleApplication::SingleApplication(const QString &appId, QObject *parent)
    : QObject(parent), m_appId(appId)
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
        m_localServer = new QLocalServer(this);
    }

    QLocalServer::removeServer(m_appId);

    if (!m_localServer->listen(m_appId)) {
        delete m_localServer;
        m_localServer = nullptr;
        QLocalServer::removeServer(m_appId);
        return true;
    }

    // 连接新连接信号
    connect(m_localServer, &QLocalServer::newConnection, this, &SingleApplication::handleNewConnection);

    return false;
}

void SingleApplication::activateExistingInstance()
{
    QLocalSocket socket;
    socket.connectToServer(m_appId);
    if (socket.waitForConnected(500)) {
        socket.write("ACTIVATE");
        socket.waitForBytesWritten(1000);
        socket.disconnectFromServer();
    }
}

void SingleApplication::handleNewConnection()
{
    QLocalSocket *clientSocket = m_localServer->nextPendingConnection();
    if (clientSocket) {
        connect(clientSocket, &QLocalSocket::readyRead, this, [this, clientSocket]() {
            QByteArray data = clientSocket->readAll();
            if (data == "ACTIVATE") {
                emit instanceActivated();
            }
            clientSocket->disconnectFromServer();
            clientSocket->deleteLater();
        });
    }
}
