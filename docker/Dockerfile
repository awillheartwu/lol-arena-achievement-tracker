# 使用官方 nginx 镜像
FROM nginx:stable-alpine

# 删除默认配置，拷贝你自己的配置（可选）
RUN rm /etc/nginx/conf.d/default.conf
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# 拷贝打包后的前端文件到 nginx 的 web 目录
COPY dist /usr/share/nginx/html

# 修复权限
RUN chmod -R 755 /usr/share/nginx/html

# 暴露端口（默认 80）
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
