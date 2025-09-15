# 使用官方 nginx 镜像
FROM nginx:stable-alpine

# 用自己的配置覆盖 Alpine 的默认站点
RUN rm -f /etc/nginx/http.d/default.conf
COPY docker/nginx.conf /etc/nginx/http.d/default.conf

# 前端产物放到默认根目录
COPY dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx","-g","daemon off;"]
