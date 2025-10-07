cmake_minimum_required(VERSION 3.16)

project(clock_cpp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets)

qt_standard_project_setup(REQUIRES 6.8)
set(CMAKE_AUTORCC ON)

set(APP_NAME "clock")

if(WIN32)
    set(SOURCES
        logo.rc
    )
endif()

qt_add_executable(${APP_NAME}
    main.cpp
    windowmanager.h
    windowmanager.cpp
    ${SOURCES}
)
set(SINGLETON_QML_FILES
        Dp.qml
)
set_source_files_properties(${SINGLETON_QML_FILES} PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)
qt_add_qml_module(${APP_NAME}
    URI Clock
    VERSION 1.0
    QML_FILES
        Main.qml
        MMenu.qml
        ${SINGLETON_QML_FILES}
        calendar.mjs
    RESOURCES resources.qrc
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${APP_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.${APP_NAME}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(${APP_NAME}
    PRIVATE Qt6::Quick Qt6::Widgets
)

# Linux 平台添加 X11 支持
if(UNIX AND NOT APPLE)
    find_package(X11 REQUIRED)
    target_include_directories(${APP_NAME} PRIVATE ${X11_INCLUDE_DIR})
    target_link_libraries(${APP_NAME} PRIVATE ${X11_LIBRARIES})
endif()

# 安装设置
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/install)
install(TARGETS ${APP_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 使用QML安装脚本 (仅在 Windows 和 macOS 下)
if(WIN32 OR APPLE)
    qt_generate_deploy_qml_app_script(
            TARGET ${APP_NAME}
            OUTPUT_SCRIPT deploy_script
            MACOS_BUNDLE_POST_BUILD
            NO_UNSUPPORTED_PLATFORM_ERROR
            NO_TRANSLATIONS
            DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    )
    install(SCRIPT ${deploy_script})
endif()


# CPack配置
set(CPACK_PACKAGE_NAME ${APP_NAME})
set(CPACK_PACKAGE_VENDOR "${PROJECT_VENDOR}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")

# 安装文件夹
set(CPACK_PACKAGE_INSTALL_DIRECTORY ${APP_NAME})

# Windows特定配置
if(WIN32)
    # NSIS安装程序配置
    set(CPACK_GENERATOR "NSIS;ZIP")
    set(CPACK_NSIS_DISPLAY_NAME ${APP_NAME})
    set(CPACK_NSIS_PACKAGE_NAME ${APP_NAME})
    set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\${APP_NAME}.exe")
    set(CPACK_NSIS_CONTACT "${PROJECT_CONTACT}")
    set(CPACK_NSIS_MODIFY_PATH ON)

    # 添加安装完成后启动应用程序的勾选框
    set(CPACK_NSIS_MUI_FINISHPAGE_RUN "$INSTDIR\\\\bin\\\\${APP_NAME}.exe")

    # 安装程序图标
    if(EXISTS "${CMAKE_SOURCE_DIR}/src/logo.ico")
        set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/src/logo.ico")
        set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/src/logo.ico")
    endif()

    # 创建桌面快捷方式
    set(CPACK_NSIS_CREATE_ICONS_EXTRA
        "CreateShortCut \\\"$DESKTOP\\\\${APP_NAME}.lnk\\\" \\\"$INSTDIR\\\\bin\\\\${APP_NAME}.exe\\\""
    )
    set(CPACK_NSIS_DELETE_ICONS_EXTRA
        "Delete \\\"$DESKTOP\\\\${APP_NAME}.lnk\\\""
    )

    # 开始菜单快捷方式
    set(CPACK_NSIS_MENU_LINKS
        "bin/${APP_NAME}.exe" "${APP_NAME}"
    )

    # 卸载程序配置
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
endif()

# Linux 特定配置
if(UNIX AND NOT APPLE)
    # 支持多种打包格式
    set(CPACK_GENERATOR "DEB;RPM;TGZ;STGZ")
    
    # 包描述
    set(CPACK_PACKAGE_DESCRIPTION "模拟时钟应用程序
一个漂亮的模拟时钟应用,支持窗口置顶、系统托盘等功能。
在 Wayland 环境下建议使用 XWayland 模式运行以获得完整的窗口置顶支持。")
    
    set(CPACK_PACKAGE_CONTACT "linxi2251@github.com")
    set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/linxi2251/clock_cpp")
    
    # DEB 包配置 (Debian/Ubuntu)
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "linxi2251")
    set(CPACK_DEBIAN_PACKAGE_SECTION "utils")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqt6core6, libqt6gui6, libqt6qml6, libqt6quick6, libqt6widgets6, libx11-6")
    set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
    
    # RPM 包配置 (Fedora/RedHat/openSUSE)
    set(CPACK_RPM_PACKAGE_LICENSE "MIT")
    set(CPACK_RPM_PACKAGE_GROUP "Applications/Productivity")
    set(CPACK_RPM_PACKAGE_REQUIRES "qt6-qtbase >= 6.0, qt6-qtdeclarative >= 6.0, libX11 >= 1.6")
    set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
    
    # 安装桌面文件和图标
    install(FILES ${CMAKE_SOURCE_DIR}/clock-xwayland.desktop
            DESTINATION share/applications
            RENAME clock.desktop)
    
    install(FILES ${CMAKE_SOURCE_DIR}/resources/clock-circle.png
            DESTINATION share/icons/hicolor/256x256/apps
            RENAME clock.png)
    
    # 安装启动脚本
    install(PROGRAMS ${CMAKE_SOURCE_DIR}/scripts/run_with_xwayland.sh
            DESTINATION bin
            RENAME clock-xwayland)
endif()

# macOS 特定配置
if(APPLE)
    set(CPACK_GENERATOR "DragNDrop;TGZ")
    set(CPACK_DMG_VOLUME_NAME "${APP_NAME}")
    set(CPACK_DMG_FORMAT "UDBZ")
endif()

# 包含CPack
include(CPack)
