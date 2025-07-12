#!/bin/bash

TAG=$(node -p "require('./package.json').version")
echo "building with tag: $TAG"

# 构建前端项目
pnpm build

# 构建 Docker 镜像（版本号 & latest）
sudo docker build -f docker/Dockerfile -t lol-arena:latest -t lol-arena:$TAG .
