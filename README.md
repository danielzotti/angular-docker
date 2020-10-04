# AngularDocker
This is an example project on how to use Angular with Docker

## Local development
- `npm run start:local`

## Configuration files

### nginx
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
### Docker

#### `.dockerignore`
```
node_modules
.git
.gitignore
.github
dist
```

#### `Dockerfile.dev`
```
FROM node:14.12.0-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
RUN npm install -g @angular/cli
COPY . ./
EXPOSE 4201
CMD ng serve --host 0.0.0.0 --port 4201
# NB: --disableHostCheck option doesn't work!
```

#### `Dockerfile`
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

## Docker `permission denied` error
For Linux console:
```
sudo groupadd docker
sudo usermod -aG docker ${USER}
newgrp docker
su - ${USER}
```

# Thanks to
- [Angular in Docker with Nginx, supporting configurations / environments, built with multi-stage Docker builds and testing with Chrome Headless](https://medium.com/@tiangolo/angular-in-docker-with-nginx-supporting-environments-built-with-multi-stage-docker-builds-bb9f1724e984)
- [Angular — Local Development With Docker-Compose](https://medium.com/bb-tutorials-and-thoughts/angular-local-development-with-docker-compose-13719b998e424)
- [Docker ARG, ENV and .env - a Complete Guide](https://vsupalov.com/docker-arg-env-variable-guide)
- [Create a MEAN APP with Angular 7, Nginx and Docker Compose](https://www.linkedin.com/pulse/create-mean-app-angular-7-nginx-docker-compose-radhouen-assakra/)