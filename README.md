# AngularDocker
This is an example project on how to use Angular with Docker

# nginx
`nginx-custom.conf`
```
server {
  listen 80;
  location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
    try_files $uri $uri/ /index.html =404;
  }
}
```
# Docker
`.dockerignore`
```
node_modules
```

`Dockerfile`
```
# Stage 0, "build-stage", based on Node.js, to build and compile Angular

FROM node:14.12.0-alpine as build-stage
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY ./ /app/
ARG configuration=production
RUN npm run build -- --output-path=./dist/out --configuration $configuration

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:1.19.2-alpine
COPY --from=build-stage /app/dist/out/ /usr/share/nginx/html
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf
```

# Docker permission denied
For Linux console:
```
sudo groupadd docker
sudo usermod -aG docker ${USER}
newgrp docker
su - ${USER}
```

# Thanks to
- https://medium.com/@tiangolo/angular-in-docker-with-nginx-supporting-environments-built-with-multi-stage-docker-builds-bb9f1724e984