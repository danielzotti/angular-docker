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