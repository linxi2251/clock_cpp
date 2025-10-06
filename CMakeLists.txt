cmake_minimum_required(VERSION 3.16)

project(clock_cpp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets)

qt_standard_project_setup(REQUIRES 6.8)
set(CMAKE_AUTORCC ON)

set(APP_NAME "Clock")

qt_add_executable(${APP_NAME}
    main.cpp
    logo.rc
)

qt_add_qml_module(${APP_NAME}
    URI Clock
    VERSION 1.0
    QML_FILES
        Main.qml
        MMenu.qml
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

# 安装设置
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/install)
install(TARGETS ${APP_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 使用QML安装脚本
qt_generate_deploy_qml_app_script(
        TARGET ${APP_NAME}
        OUTPUT_SCRIPT deploy_script
        MACOS_BUNDLE_POST_BUILD
        NO_UNSUPPORTED_PLATFORM_ERROR
        NO_TRANSLATIONS
        DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
)
install(SCRIPT ${deploy_script})


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

# 包含CPack
include(CPack)
