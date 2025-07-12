#!/bin/bash

# 读取 package.json 中的版本号
VERSION=$(jq -r .version package.json)

# 构建前端项目
pnpm build

# 构建 Docker 镜像（版本号 & latest）
sudo docker build -t lol-arena:$VERSION -t lol-arena:latest .
