# AngularDocker
This is an example project on how to use Angular with Docker

# TL;DR
- Local development (**without docker**) with "classic" Angular CLI
    - `npm run start` aka `ng serve`
- Local development: every change to code it refreshes
    - `npm run docker:start:local`
- Dev version served by nginx
    - `npm run docker:start:dev`
- Prod version served by nginx
    - `npm run docker:start:prod`

## Configuration files

### nginx
Always return the index.html file (for SPA): `nginx-custom.conf`
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

#### `Dockerfile.local`
```
FROM node:14.12.0-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
RUN npm install -g @angular/cli
COPY . .
EXPOSE 4201
CMD ng serve --host 0.0.0.0 --port 4201
# NB: --disableHostCheck option doesn't work!
```

#### `Dockerfile` (`dev` and `prod`)
```
# Stage 0, "build-stage", based on Node.js, to build and compile Angular
FROM node:14.12.0-alpine as build-stage
WORKDIR app
COPY package*.json /app/
RUN npm install
RUN npm install -g @angular/cli @angular-devkit/build-angular
COPY . .
ARG configuration=production
RUN npm run build -- --outputPath=/app/dist --configuration=${configuration}

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:1.19.2-alpine
COPY --from=build-stage /app/dist/ /usr/share/nginx/html/
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf
```

#### `docker-compose.local.yml`
```
version: '3'

services:
  angular:
    build:
      context: .
      dockerfile: Dockerfile.local
    ports:
      - "4201:4201"
    container_name: angular-docker_local
    image: dz/angular-docker_local
    volumes:
      - .:/app
      - /app/node_modules
```

#### `docker-compose.{env}.yml`
Note that `{env}` must be replaced by a string (`dev`, `prod` or a different environment name)
```
version: '3'

services:
  angular:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - configuration={env}
    container_name: angular-docker_{env}
    image: dz/angular-docker_{env}
    ports:
      - "80:80"
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