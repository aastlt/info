FROM alpine
RUN apk update \
&& apk add nginx \
&& adduser -D -g 'www' www && mkdir /www && chown -R www:www /var/lib/nginx && chown -R www:www /www
COPY ./index.html /www
COPY ./nginx.conf /etc/nginx/
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]



