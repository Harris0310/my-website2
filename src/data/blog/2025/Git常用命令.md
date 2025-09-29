---
author: C Y
pubDatetime: 2025-09-16T14:00:00Z
title: 网上搜集的常用Git命令
description: "网上搜集的常用Git命令"
tags:
  - Git
  - 版本控制
  - 开发工具
---
## 我自己的丝滑提交小连招
普通推送
```markdown
git add .  
git commit -m "update"  
git push origin main
```
强制推送
```markdown
git add .  
git commit -m "update"  
git push -f origin main
```
## Git 工作流示意图
工作区 → git add → 暂存区 → git commit → 本地仓库 → git push → 远程仓库

## 1. 基础配置
设置全局用户名和邮箱（提交时显示作者信息）
```markdown
git config --global user.name "你的用户名"  
git config --global user.email "你的邮箱"
```
设置 Git 默认编辑器为 VS Code
```markdown
git config --global core.editor "code --wait"
```
## 2. 仓库初始化与克隆
初始化本地仓库
```markdown
git init
```
克隆远程仓库（HTTPS 或 SSH）
```markdown
git clone https://github.com/用户名/仓库名.git  
git clone git@github.com:用户名/仓库名.git
```
克隆指定分支
```markdown
git clone -b 分支名 仓库地址
```
## 3. 提交与推送
查看文件状态
```markdown
git status
```
添加所有修改到暂存区
```markdown
git add .
```
添加指定文件
```markdown
git add 文件名
```
提交到本地仓库（提交描述）
```markdown
git commit -m ""
```
推送到远程分支（首次推送加 -u）
```markdown
git push -u 本地分支 分支名
```
强制推送（谨慎使用）
```markdown
git push -f 本地分支 分支名
```
## 4. 分支操作
查看所有分支（本地+远程）
```markdown
git branch -a
```
创建新分支
```markdown
git branch 分支名
```
切换分支
```markdown
git checkout 分支名
```
创建并切换分支
```markdown
git checkout -b 新分支名
```
删除本地分支
```markdown
git branch -d 分支名
```
删除远程分支
```markdown
git push origin --delete 分支名
```
合并分支到当前分支
```markdown
git merge 分支名
```
## 5. 远程仓库管理
查看远程仓库地址
```markdown
git remote -v
```
添加远程仓库
```markdown
git remote add origin 仓库地址
```
修改远程仓库地址
```markdown
git remote set-url origin 新地址
```
拉取远程分支最新代码
```markdown
git pull origin 分支名
```
拉取并强制覆盖本地（谨慎！）
```markdown
git fetch --all  
git reset --hard origin/分支名
```
## 6. 撤销与回退
撤销工作区修改（未 add）
```markdown
git checkout -- 文件名
```
撤销暂存区修改（已 add）
```markdown
git reset HEAD 文件名
```
回退到某次提交（保留修改）
```markdown
git reset --soft 提交ID
```
彻底回退到某次提交（丢弃修改）
```markdown
git reset --hard 提交ID
```
生成撤销某次提交的新提交
```markdown
git revert 提交ID
```
## 7. 日志与差异
查看提交历史
```markdown
git log
```
简洁版提交历史
```markdown
git log --oneline
```
查看文件修改内容
```markdown
git diff
```
查看某次提交的改动
```markdown
git show 提交ID
```
## 8. 忽略文件（在.gitignore文件里写入）
匹配规则:  
忽略所有扩展名为 .log的文件。  
```markdown
*.log
```  
 
忽略类似 temp1, tempA等文件（?匹配单个字符）。 
```markdown
temp?
```
仅忽略根目录下的 project.log文件，不忽略子目录中的。 
```markdown
/project.log
```  
忽略所有名为 logs的目录及其内容。
```markdown
logs/
```  
忽略任何目录下的名为 temp的文件或目录（**匹配任意中间目录）。
```markdown
**/temp
```    
​​不忽略​​ important.log文件（!用于否定忽略，此规则需在忽略 *.log后生效）。
```markdown
!important.log
```

## 9. 临时保存更改（Stash）
保存当前修改到临时栈
```markdown
git stash
```
恢复最近保存的修改
```markdown
git stash pop
```
查看所有暂存记录
```markdown
git stash list
```
## 10. 标签管理
创建标签
```markdown
git tag v1.0.0
```
推送标签到远程
```markdown
git push origin v1.0.0
```
删除标签
```markdown
git tag -d v1.0.0
```