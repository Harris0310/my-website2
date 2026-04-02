---
author: C Y
pubDatetime: 2026-04-02T12:00:00Z
title: Claude Code 一览
description: "Claude Code 常用命令与 Skills 使用指南"
tags:
  - Claude Code
  - AI 编程
  - 工具使用
---

# Claude Code 一览

Claude Code 是 Anthropic 官方推出的 CLI 编程助手,基于 Claude 模型,可以帮助开发者完成代码编写、调试、重构等任务。本文整理了常用的命令与 Skills,方便快速查阅。

---

## 一、核心命令

### /help

显示帮助信息,列出所有可用命令。

```
/help
```

---

### /model

切换当前对话使用的模型。

```
/model <模型名>
```

**可用模型**:
- `sonnet` - Claude Sonnet 4.6 (平衡之选)
- `opus` - Claude Opus 4.6 (最强推理能力)
- `haiku` - Claude Haiku 4.5 (极速响应)

---

### /fast

切换快速模式,使用更快响应的模型同时保持较高质量。

```
/fast
```

---

## 二、代码处理命令

### /debug

调试命令,用于分析代码中的 bug 并提供修复建议。

```
/debug <问题描述>
```

**示例**:
```
/debug 程序在处理大文件时内存占用过高
```

**功能**:
- 分析错误信息和堆栈跟踪
- 定位问题根源
- 提供具体的修复代码

---

### /simplify

代码审查与重构命令,自动检查代码的可复用性、质量和效率问题,并直接修复。

```
/simplify
```

**功能**:
- 识别重复代码,建议可复用的工具函数
- 发现 hack 模式(冗余状态、参数膨胀、字符串类型等)
- 检测性能问题(重复计算、N+1 查询、内存泄漏等)
- 自动应用修复

---

### /test

测试驱动开发命令,在编写代码前先写测试用例。

```
/test
```

**功能**:
- 根据需求先编写测试用例
- 明确预期行为
- 再实现代码通过测试

---

### /plan

进入计划模式,设计实现方案和架构规划。

```
/plan
```

**功能**:
- 探索代码库理解现状
- 设计详细的实现方案
- 与用户确认后再执行

---

### /verify

完成前验证,确保工作真正通过。

```
/verify
```

---

### /review

请求代码审查。

```
/review
```

---

## 三、Git 与协作命令

### /commit

创建 Git 提交,会自动分析更改并生成提交信息。

```
/commit
```

---

### /review-pr

查看 GitHub PR 的评论。

```
/review-pr <pr编号>
```

---

## 四、会话控制命令

### /clear

清除当前会话的上下文,但保留 git 相关状态。

```
/clear
```

---

### /exit

退出 Claude Code。

```
/exit
```

---

## 五、Skills

Skills 是 Claude Code 的扩展功能,使用 `/<skill-name>` 格式调用。

### 开发流程 Skills

| Skill 名称 | 用途 |
|-----------|------|
| brainstorming | 头脑风暴,需求分析 |
| systematic-debugging | 系统化调试 |
| test-driven-development | 测试驱动开发 |
| verification-before-completion | 完成前验证 |
| receiving-code-review | 接收代码审查反馈 |
| requesting-code-review | 请求代码审查 |
| executing-plans | 执行计划 |
| writing-plans | 编写计划规范 |
| writing-skills | 编写新 Skills |
| simplify | 代码审查与重构 |
| using-superpowers | Skills 使用指南 |

---

### 内容创作 Skills (baoyu 系列)

| Skill 名称 | 用途 |
|-----------|------|
| baoyu-translate | 文章/文档翻译 |
| baoyu-markdown-to-html | Markdown 转 HTML |
| baoyu-url-to-markdown | URL 转 Markdown |
| baoyu-post-to-wechat | 推送至微信公众号 |
| baoyu-post-to-weibo | 推送至微博 |
| baoyu-article-illustrator | 文章插图生成 |
| baoyu-comic | 知识漫画创建 |
| baoyu-infographic | 信息图制作 |
| baoyu-slide-deck | PPT/幻灯片制作 |
| baoyu-xhs-images | 小红书图文系列 |
| baoyu-youtube-transcript | YouTube 字幕获取 |
| baoyu-compress-image | 图片压缩优化 |
| baoyu-imagine | AI 图片生成 |
| baoyu-danger-gemini-web | Gemini Web API |

---

### 文档处理 Skills

| Skill 名称 | 用途 |
|-----------|------|
| pdf | PDF 读取/合并/分割/旋转 |
| docx | Word 文档编辑 |
| pptx | PowerPoint 处理 |
| xlsx | Excel/CSV 处理 |
| frontend-design | 前端界面设计 |

---

### 配置与 API Skills

| Skill 名称 | 用途 |
|-----------|------|
| update-config | 配置 Claude Code 行为 |
| claude-api | Anthropic API / SDK 使用 |
| loop | 定时重复执行任务 |
| release-skills | 通用发布流程 |
| skill-creator | 创建/优化 Skills |

---

## 六、Agent 工具

Claude Code 支持启动专门的 Agent 来处理复杂任务:

```
使用 <agent-type> agent <任务描述>
```

| Agent 类型 | 用途 |
|-----------|------|
| general-purpose | 通用任务处理、研究复杂问题 |
| Explore | 代码库探索、搜索文件、理解代码结构 |
| Plan | 设计实现方案、架构规划 |
| claude-code-guide | Claude Code 功能相关问题 |

**使用示例**:
```
使用 Explore agent 查找项目中所有与认证相关的代码
使用 Plan agent 规划新功能的实现方案
```

---

## 七、常见使用场景

### 1. 代码调试
```
/debug 点击按钮后控制台报错 "Cannot read property of undefined"
```

### 2. 代码审查
```
/simplify
```
自动审查当前 git 更改的代码。

### 3. 计划新功能
```
/plan
然后描述: 添加用户登录功能,使用 JWT 认证
```

### 4. TDD 开发流程
```
/test
描述: 为计算器函数编写加法测试用例
```

### 5. 定时监控
```
/loop 10m 检查服务器是否正常运行
```

### 6. 批量任务处理
```
使用 general-purpose agent 并行处理:
1. 修复 login.ts 的类型错误
2. 更新 user.service.ts 的文档注释
3. 添加单元测试
```

---

## 八、快捷键与 Tips

| 操作 | 快捷键/方式 |
|------|------------|
| 切换模型 | `/model <模型>` |
| 快速模式 | `/fast` |
| 中断当前执行 | `Ctrl+C` |
| 查看可用命令 | `/help` |
| 查看当前任务 | `/tasks` |

**使用建议**:
- 复杂任务先用 `/plan` 规划,避免走弯路
- 修复 bug 用 `/debug` 可以获得更系统的分析
- 重要代码更改前用 `/review` 请求审查
- 定期查看 `/help` 获取最新功能更新

---

## 九、注意事项

- Claude Code 的建议仅供参考,执行敏感操作前请仔细审查
- 危险操作(如删除文件、强制推送)会要求确认
- 涉及外部系统的操作建议先备份数据

---

## 十、参考资源

- [Claude Code 官方文档](https://docs.claude.com/claude-code)
- [Anthropic API 文档](https://docs.anthropic.com/)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
