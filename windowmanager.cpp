#include "windowmanager.h"
#include <QDebug>
#include <QWindow>
#include <QGuiApplication>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

#ifdef Q_OS_LINUX
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <dlfcn.h>
#endif

WindowManager::WindowManager(QObject *parent)
    : QObject(parent)
{
    m_updateTimer = new QTimer(this);
    m_updateTimer->setInterval(100);
    m_updateTimer->setSingleShot(true);
    connect(m_updateTimer, &QTimer::timeout, this, &WindowManager::applyStayOnTop);
    
#ifdef Q_OS_LINUX
    // 检测当前运行的显示服务器
    QString platformName = QGuiApplication::platformName();
    qDebug() << "检测到的平台:" << platformName;
    
    if (platformName == "wayland") {
        qWarning() << "Wayland 环境检测到";
        qWarning() << "注意: Wayland 对窗口置顶有严格限制,可能需要使用 KWin 脚本或配置";
    } else if (platformName == "xcb") {
        qDebug() << "X11 环境检测到,将使用 X11 API";
    }
#endif
}

void WindowManager::setWindow(QQuickWindow *window)
{
    if (m_window == window)
        return;

    m_window = window;
    
    if (m_window) {
        // 确保窗口已经创建
        connect(m_window, &QQuickWindow::visibleChanged, this, [this]() {
            if (m_window->isVisible() && m_stayOnTop) {
                m_updateTimer->start();
            }
        });
    }
}

void WindowManager::setStayOnTop(bool stayOnTop)
{
    if (m_stayOnTop == stayOnTop)
        return;

    m_stayOnTop = stayOnTop;
    emit stayOnTopChanged();

    updateWindowFlags();
}

void WindowManager::updateWindowFlags()
{
    if (!m_window)
        return;

    Qt::WindowFlags flags = m_window->flags();
    
    // 移除旧的置顶标志
    flags &= ~Qt::WindowStaysOnTopHint;
    
    if (m_stayOnTop) {
        flags |= Qt::WindowStaysOnTopHint;
    }

    m_window->setFlags(flags);
    
    // 延迟应用以确保窗口系统处理了标志更改
    if (m_window->isVisible()) {
        m_updateTimer->start();
    }
}

void WindowManager::applyStayOnTop()
{
    if (!m_window || !m_window->isVisible())
        return;

#ifdef Q_OS_LINUX
    QString platformName = QGuiApplication::platformName();
    
    if (platformName == "xcb") {
        // X11 环境
        setX11StayOnTop(m_stayOnTop);
    } else if (platformName == "wayland") {
        // Wayland 环境
        qWarning() << "Wayland 环境下窗口置顶功能受限";
        qWarning() << "建议使用以下方法之一:";
        qWarning() << "1. 在 KDE 系统设置中为此应用创建窗口规则";
        qWarning() << "2. 使用 XWayland 运行应用: QT_QPA_PLATFORM=xcb ./clock";
        qWarning() << "3. 安装并启用 KWin 脚本来支持应用置顶请求";
    }
#elif defined(Q_OS_WIN)
    // Windows 平台: Qt::WindowStaysOnTopHint 在 Windows 下通常工作良好
    // updateWindowFlags() 中已经设置了标志,这里只需要刷新窗口
    qDebug() << "Windows 平台: 使用 Qt::WindowStaysOnTopHint";
#elif defined(Q_OS_MACOS)
    // macOS 平台: Qt::WindowStaysOnTopHint 在 macOS 下也能正常工作
    qDebug() << "macOS 平台: 使用 Qt::WindowStaysOnTopHint";
#endif

    // 强制窗口提升到前台
    if (m_stayOnTop) {
        m_window->raise();
        m_window->requestActivate();
    }
}

#ifdef Q_OS_LINUX
void WindowManager::setX11StayOnTop(bool stayOnTop)
{
    if (!m_window)
        return;

    // 获取本地窗口句柄
    WId windowId = m_window->winId();
    
    // 打开 X11 display
    Display *display = XOpenDisplay(nullptr);
    
    if (!display) {
        qWarning() << "无法打开 X11 Display,可能运行在 Wayland 下";
        return;
    }

    // 获取必要的 atoms
    Atom wmState = XInternAtom(display, "_NET_WM_STATE", False);
    Atom wmStateAbove = XInternAtom(display, "_NET_WM_STATE_ABOVE", False);
    Atom wmStateStaysOnTop = XInternAtom(display, "_NET_WM_STATE_STAYS_ON_TOP", False);

    XEvent event;
    memset(&event, 0, sizeof(event));
    
    event.type = ClientMessage;
    event.xclient.window = windowId;
    event.xclient.message_type = wmState;
    event.xclient.format = 32;
    event.xclient.data.l[0] = stayOnTop ? 1 : 0; // 1 = _NET_WM_STATE_ADD, 0 = _NET_WM_STATE_REMOVE
    event.xclient.data.l[1] = wmStateAbove;
    event.xclient.data.l[2] = wmStateStaysOnTop;
    event.xclient.data.l[3] = 1; // Source indication: 1 = application

    // 发送事件到根窗口
    Window rootWindow = DefaultRootWindow(display);
    XSendEvent(display, rootWindow, False,
               SubstructureRedirectMask | SubstructureNotifyMask,
               &event);
    
    XFlush(display);
    XCloseDisplay(display);
    
    qDebug() << "X11 窗口置顶状态已设置:" << stayOnTop;
}
#endif

void WindowManager::activateWindow()
{
    if (!m_window)
        return;

    // 显示窗口(如果被隐藏)
    if (!m_window->isVisible()) {
        m_window->show();
    }

    // 如果窗口被最小化,恢复它
    if (m_window->windowState() & Qt::WindowMinimized) {
        m_window->setWindowState(Qt::WindowNoState);
    }

    // 提升窗口到前台
    m_window->raise();
    
    // 请求激活窗口(获得焦点)
    m_window->requestActivate();

#ifdef Q_OS_WIN
    // Windows 特定代码:强制激活窗口
    HWND hwnd = reinterpret_cast<HWND>(m_window->winId());
    
    // 允许设置前台窗口
    DWORD currentThreadId = GetCurrentThreadId();
    DWORD foregroundThreadId = GetWindowThreadProcessId(GetForegroundWindow(), NULL);
    
    if (currentThreadId != foregroundThreadId) {
        // 附加到前台线程的输入队列
        AttachThreadInput(currentThreadId, foregroundThreadId, TRUE);
    }
    
    // 恢复窗口(如果被最小化)
    if (IsIconic(hwnd)) {
        ShowWindow(hwnd, SW_RESTORE);
    }
    
    // 设置为前台窗口
    SetForegroundWindow(hwnd);
    SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0, 
                 SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
    SetFocus(hwnd);
    
    if (currentThreadId != foregroundThreadId) {
        // 分离线程输入队列
        AttachThreadInput(currentThreadId, foregroundThreadId, FALSE);
    }
    
    qDebug() << "Windows 窗口已被激活并提到前台";
#else
    qDebug() << "窗口已被激活";
#endif
}
