# FilehHash - 文件哈希计算工具

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

一个简单高效的命令行文件哈希计算工具，支持MD5、SHA1和SHA256算法。

## 特性

- 支持多种哈希算法：MD5、SHA1、SHA256
- 支持单个或批量文件处理
- 清晰的输出格式
- 快速高效的计算性能
- 支持错误处理和文件验证
- 支持标准Linux/Unix风格的.deb包分发

## 安装

### 从.deb包安装（推荐）

```bash
# 下载并安装
sudo dpkg -i filehash_1.0.0-1_amd64.deb

# 如果有依赖问题，运行
sudo apt-get install -f
```

### 从源码编译

```bash
# 克隆仓库
git clone https://github.com/caojiying002/filehash-tool.git
cd filehash-tool

# 安装依赖
sudo apt-get install build-essential libssl-dev

# 编译
make

# 安装（可选）
sudo make install
```

## 使用方法

### 基本使用

```bash
# 计算文件的MD5哈希值（默认）
filehash file.txt

# 计算SHA1哈希值
filehash -s file.txt

# 计算SHA256哈希值
filehash -S file.txt

# 计算所有支持的哈希值
filehash -a file.txt
```

### 批量处理

```bash
# 处理多个文件
filehash file1.txt file2.txt file3.txt

# 使用通配符
filehash *.txt

# 处理指定路径下的所有文件
filehash /path/to/files/*
```

### 命令行选项

```
-m, --md5      计算MD5哈希值（默认）
-s, --sha1     计算SHA1哈希值
-S, --sha256   计算SHA256哈希值
-a, --all      计算所有哈希值
-h, --help     显示帮助信息
-v, --version  显示版本信息
```

## 输出示例

```
MD5 (d41d8cd98f00b204e9800998ecf8427e) = empty.txt
SHA1 (da39a3ee5e6b4b0d3255bfef95601890afd80709) = empty.txt
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = empty.txt
```

## 示例

更多详细的使用示例请查看 [examples/usage.txt](examples/usage.txt)

## 开发构建

### 构建项目

```bash
# 普通构建
./scripts/build.sh

# 构建.deb包
./scripts/build-deb.sh
```

### 运行测试

```bash
# 运行完整测试套件
./tests/run-tests.sh

# 或者通过make
make test
```

## 技术规格

- **语言**: C99
- **依赖**: OpenSSL (libssl-dev)
- **构建系统**: GNU Make
- **包格式**: Debian .deb
- **支持平台**: Linux (amd64)

## 项目结构

### 目录结构

```
filehash-tool/
├── src/                 # 源代码
├── docs/               # 文档
├── debian/             # Debian包配置
├── scripts/            # 构建脚本
├── tests/              # 测试套件
└── Makefile           # 构建配置
```

### 贡献指南

1. Fork 仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证

本项目采用 GNU General Public License v3.0 许可证。详见 [LICENSE](../LICENSE) 文件。

## 作者

- **Cao Jiying** - [caojiying002@126.com](mailto:caojiying002@126.com)

## 致谢

- OpenSSL项目提供的加密函数库
- Debian社区的打包工具和文档

---

如果遇到问题请提交 [Issue](https://github.com/caojiying002/filehash-tool/issues)。