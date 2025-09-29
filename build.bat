@echo off
pnpm build
explorer dist
echo 构建完成，dist 文件夹已打开，直接全选打包上传即可！
pause