# 打包快速指南

## 🚀 快速打包

### 使用自动脚本 (推荐)

```bash
./build_package.sh
```

脚本会引导您选择要生成的包格式。

### 手动打包

```bash
# 1. 配置 Release 构建
cmake -B build-release -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr

# 2. 编译
cmake --build build-release -j$(nproc)

# 3. 生成包
cd build-release

# 生成 DEB 包 (Debian/Ubuntu)
cpack -G DEB

# 生成 RPM 包 (Fedora/openSUSE)
cpack -G RPM

# 生成 TGZ 包 (通用)
cpack -G TGZ

# 生成所有格式
cpack
```

## 📦 生成的包

执行完成后,在 `build-release/` 目录下会生成:

- `clock_0.1_amd64.deb` - Debian/Ubuntu 安装包
- `clock-0.1-1.x86_64.rpm` - Fedora/openSUSE 安装包  
- `clock-0.1-Linux.tar.gz` - 通用压缩包
- `clock-0.1-Linux.sh` - 自解压安装包

## 💿 安装方法

### DEB 包 (Debian/Ubuntu/Mint)

```bash
sudo dpkg -i build-release/clock_0.1_amd64.deb
sudo apt-get install -f  # 自动解决依赖
```

### RPM 包 (Fedora/openSUSE)

```bash
# Fedora
sudo dnf install build-release/clock-0.1-1.x86_64.rpm

# openSUSE
sudo zypper install build-release/clock-0.1-1.x86_64.rpm
```

### TGZ 包 (通用)

```bash
tar -xzf build-release/clock-0.1-Linux.tar.gz
cd clock-0.1-Linux
sudo cp -r usr/* /usr/
```

## 🧪 测试包

### 查看包内容

```bash
# DEB
dpkg -c build-release/clock_0.1_amd64.deb
dpkg -I build-release/clock_0.1_amd64.deb

# RPM
rpm -qlp build-release/clock-0.1-1.x86_64.rpm
rpm -qip build-release/clock-0.1-1.x86_64.rpm

# TGZ
tar -tzf build-release/clock-0.1-Linux.tar.gz
```

### 在容器中测试

```bash
# Ubuntu
docker run -it ubuntu:22.04
apt update && apt install ./clock_0.1_amd64.deb

# Fedora  
docker run -it fedora:latest
dnf install ./clock-0.1-1.x86_64.rpm
```

## 📂 包内容

安装后的文件结构:

```
/usr/bin/clock                      # 主程序
/usr/bin/clock-xwayland             # XWayland 启动脚本
/usr/share/applications/clock.desktop   # 桌面启动器
/usr/share/icons/.../clock.png      # 应用图标
/usr/share/doc/clock/               # 文档
    README.md
    WAYLAND_SOLUTION.md
    PACKAGING.md
```

## ⚙️ 配置选项

编辑 `CMakeLists.txt` 中的 CPack 配置:

```cmake
# 修改版本号
project(clock_cpp VERSION 0.2.0 ...)

# 修改维护者
set(CPACK_PACKAGE_CONTACT "your@email.com")

# 修改描述
set(CPACK_PACKAGE_DESCRIPTION "Your description")

# 修改依赖 (DEB)
set(CPACK_DEBIAN_PACKAGE_DEPENDS "pkg1, pkg2")

# 修改依赖 (RPM)
set(CPACK_RPM_PACKAGE_REQUIRES "pkg1, pkg2")
```

## 🐛 常见问题

**Q: 生成 RPM 时提示没有 rpmbuild**

```bash
# Fedora/RHEL
sudo dnf install rpm-build

# Debian/Ubuntu
sudo apt install rpm
```

**Q: 依赖问题**

```bash
# DEB
sudo apt-get install -f

# RPM
sudo dnf install --skip-broken
```

**Q: 权限问题**

打包不需要 root 权限,只有安装时需要。

## 📝 详细文档

查看 `PACKAGING.md` 获取完整的打包文档。

## ✅ 已测试

- ✅ DEB 包生成成功
- ✅ TGZ 包生成成功  
- ✅ 包含所有必要文件
- ✅ 桌面文件正确
- ✅ 图标安装正确
- ✅ 文档包含完整

## 🎉 完成!

现在您可以分发这些安装包了!
