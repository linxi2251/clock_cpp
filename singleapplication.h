#ifndef SINGLEAPPLICATION_H
#define SINGLEAPPLICATION_H

#include <QObject>
#include <QLocalServer>
#include <QLocalSocket>

// 单实例应用管理器
class SingleApplication : public QObject {
    Q_OBJECT

public:
    explicit SingleApplication(const QString &appId, QObject *parent = nullptr);
    ~SingleApplication();

    bool isRunning();
    void activateExistingInstance();

signals:
    void instanceActivated();

private slots:
    void handleNewConnection();

private:
    QString m_appId;
    QLocalServer *m_localServer{nullptr};
};

#endif // SINGLEAPPLICATION_H
