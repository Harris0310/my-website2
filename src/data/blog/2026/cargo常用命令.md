---
author: C Y
pubDatetime: 2026-01-31T11:30:00Z
title: Cargo 常用命令
description: "Rust 包管理工具 Cargo 常用命令速查手册"
tags:
  - Rust
  - Cargo
  - 包管理
  - 开发工具
---

# Cargo 常用命令速查手册

本文档整理了 Rust 包管理工具 Cargo 的核心命令,涵盖项目创建、依赖管理、构建运行、发布等场景,适合 Rust 开发者快速查阅。

## 一、项目创建与初始化

### 1. 创建新项目

创建可执行项目(binary)
```bash
cargo new my-project
```

创建库项目(library)
```bash
cargo new --lib my-lib
```

### 2. 初始化现有目录

将现有目录初始化为 Cargo 项目
```bash
cargo init
```

初始化为库项目
```bash
cargo init --lib
```

## 二、依赖管理

### 1. 添加依赖

添加最新版本依赖到 Cargo.toml
```bash
cargo add serde
```

添加指定版本依赖
```bash
cargo add serde@1.0.150
```

添加开发依赖(dev-dependencies)
```bash
cargo add --dev tokio-test
```

添加构建依赖(build-dependencies)
```bash
cargo add --build cc
```

从 Git 仓库添加依赖
```bash
cargo add --git https://github.com/serde-rs/serde.git serde
```

添加带特性的依赖
```bash
cargo add serde --features "derive"
```

### 2. 移除依赖

从 Cargo.toml 移除依赖
```bash
cargo remove serde
```

移除开发依赖
```bash
cargo remove --dev tokio-test
```

### 3. 更新依赖

更新 Cargo.lock 锁定的依赖到最新兼容版本
```bash
cargo update
```

更新指定包
```bash
cargo update -p serde
```

## 三、构建与运行

### 1. 构建项目

Debug 模式构建(默认)
```bash
cargo build
```

Release 模式构建(优化编译)
```bash
cargo build --release
```

仅检查代码,不构建
```bash
cargo check
```

### 2. 运行项目

运行开发版本
```bash
cargo run
```

运行 Release 版本
```bash
cargo run --release
```

传递参数运行
```bash
cargo run -- --help
```

## 四、测试与文档

### 1. 运行测试

运行所有测试
```bash
cargo test
```

运行指定测试函数
```bash
cargo test test_name
```

运行测试并显示输出
```bash
cargo test -- --show-output
```

运行单个文件中的测试
```bash
cargo test --lib path::to::module
```

并行运行测试(默认)
```bash
cargo test --test-threads=4
```

串行运行测试
```bash
cargo test --test-threads=1
```

### 2. 文档生成

生成并打开文档
```bash
cargo doc --open
```

生成文档(不打开)
```bash
cargo doc
```

包含私有项的文档
```bash
cargo doc --document-private-items
```

检查文档中的示例代码
```bash
cargo test --doc
```

## 五、发布与清理

### 1. 打包发布

准备发布(检查可发布性)
```bash
cargo publish --dry-run
```

发布到 crates.io
```bash
cargo publish
```

### 2. 清理缓存

清理 Debug 构建产物
```bash
cargo clean
```

清理 Release 构建产物
```bash
cargo clean --release
```

清理指定 target
```bash
cargo clean --target-dir my-target
```

## 六、工作空间(Workspace)

### 1. 创建工作空间

创建工作空间
```bash
cargo new my-workspace
```

### 2. 在工作空间中添加成员

在 Cargo.toml 中配置
```toml
[workspace]
members = ["member1", "member2", "member3"]
```

## 七、检查与分析

### 1. 代码检查

运行 Clippy(Rust linter)
```bash
cargo clippy
```

Clippy 并自动修复警告
```bash
cargo clippy --fix
```

检查指定目标
```bash
cargo clippy --bin my-bin
```

### 2. 代码格式化

格式化代码
```bash
cargo fmt
```

检查格式化问题
```bash
cargo fmt --check
```

### 3. 其他检查

检查未使用的依赖
```bash
cargo udeps
```

生成构建统计信息
```bash
cargo build --timings
```

## 八、环境变量与配置

### 1. 设置环境变量

运行时设置环境变量
```bash
RUST_LOG=debug cargo run
```

设置多个环境变量
```bash
RUST_LOG=debug DATABASE_URL=postgres://localhost/db cargo run
```

### 2. 配置 Cargo

配置默认工具链
```bash
rustup default stable
```

查看当前配置
```bash
cargo config get build.target
```

## 九、高级命令

### 1. 安装二进制工具

从 crates.io 安装工具
```bash
cargo install ripgrep
```

从 Git 仓库安装
```bash
cargo install --git https://github.com/BurntSushi/ripgrep ripgrep
```

列出已安装的工具
```bash
cargo install --list
```

卸载工具
```bash
cargo uninstall ripgrep
```

### 2. 扩展命令

使用第三方 cargo 命令
```bash
cargo install cargo-edit
cargo add dependency
```

### 3. 交叉编译

编译为其他平台
```bash
cargo build --target x86_64-unknown-linux-musl
```

查看所有可用 target
```bash
rustup target list
```

添加 target
```bash
rustup target add x86_64-unknown-linux-musl
```

## 十、调试与排错

### 1. 查看依赖树

查看依赖关系
```bash
cargo tree
```

查看反向依赖
```bash
cargo tree --invert
```

查看指定包的依赖
```bash
cargo tree -p serde
```

### 2. 查看包信息

查看包详细信息
```bash
cargo package
```

查看包内容(不打包)
```bash
cargo package --allow-dirty
```

### 3. 验证项目

验证Cargo.toml 和 Cargo.lock
```bash
cargo verify-project
```

## 十一、常用别名

可以通过 `.cargo/config.toml` 配置命令别名

```toml
[alias]
b = "build"
r = "run"
t = "test"
c = "check"
br = "build --release"
rr = "run --release"
```

使用示例
```bash
cargo br
cargo rr
```

## 十二、性能优化

### 1. 并行编译

使用多核编译
```bash
CARGO_BUILD_JOBS=4 cargo build
```

### 2. 增量编译

启用增量编译(默认已启用)
```bash
CARGO_INCREMENTAL=1 cargo build
```

### 3. 链接优化

使用 lld 链接器(更快)
```bash
cargo build --release
```
在 `.cargo/config.toml` 中配置
```toml
[target.x86_64-unknown-linux-gnu]
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=lld"]
```

## 十三、实用技巧

### 1. 查看命令帮助

查看所有可用命令
```bash
cargo --help
```

查看具体命令帮助
```bash
cargo build --help
```

### 2. 查看版本信息

查看 Cargo 版本
```bash
cargo --version
```

查看 Rust 版本
```bash
rustc --version
```

查看 Rust 工具链信息
```bash
rustup show
```

### 3. 项目信息

显示项目元数据
```bash
cargo metadata --format-version 1
```

### 4. 快速搜索包

在 crates.io 搜索包
```bash
cargo search serde
```

按描述搜索
```bash
cargo search "http client"
```

## 十四、工作流程示例

### 1. 典型开发流程

```bash
# 创建项目
cargo new my-app
cd my-app

# 添加依赖
cargo add tokio --features full

# 编写代码后
cargo check
cargo test

# 运行开发版本
cargo run

# 发布前检查
cargo clippy
cargo fmt --check

# Release 构建
cargo build --release

# 发布到 crates.io
cargo publish
```

### 2. 调试流程

```bash
# 开发模式运行
cargo run

# 设置日志级别
RUST_LOG=debug cargo run

# 运行测试
cargo test

# 检查代码
cargo clippy

# 分析编译时间
cargo build --timings
```

## 十五、工具推荐

- **在线资源**:[crates.io](https://crates.io/)(Rust 包注册中心)、[docs.rs](https://docs.rs/)(文档网站)
- **本地编辑器**:VS Code(安装 rust-analyzer 插件)、IntelliJ IDEA(Rust 插件)
- **辅助工具**:cargo-watch(自动重新编译)、cargo-expand(宏展开)
