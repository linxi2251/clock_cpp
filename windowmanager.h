#ifndef WINDOWMANAGER_H
#define WINDOWMANAGER_H

#include <QObject>
#include <QQuickWindow>
#include <QTimer>

class WindowManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool stayOnTop READ stayOnTop WRITE setStayOnTop NOTIFY stayOnTopChanged)

public:
    explicit WindowManager(QObject *parent = nullptr);

    bool stayOnTop() const { return m_stayOnTop; }
    void setStayOnTop(bool stayOnTop);

    Q_INVOKABLE void setWindow(QQuickWindow *window);
    Q_INVOKABLE void activateWindow();

signals:
    void stayOnTopChanged();

private:
    void updateWindowFlags();
    void applyStayOnTop();
    
#ifdef Q_OS_LINUX
    void setX11StayOnTop(bool stayOnTop);
#endif

    QQuickWindow *m_window = nullptr;
    bool m_stayOnTop = false;
    QTimer *m_updateTimer = nullptr;
};

#endif // WINDOWMANAGER_H
