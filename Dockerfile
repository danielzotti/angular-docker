# Stage 0, "build-stage", based on Node.js, to build and compile Angular

FROM node:14.12.0-alpine as build-stage

WORKDIR app

# copy package.json and package-lock.json into workdir /app
COPY package*.json ./

RUN npm install

RUN npm install -g @angular/cli @angular-devkit/build-angular

# copy all files from workspace into workdir /app
COPY . .

#ARG configuration=production

# run the build inside workdir /app with output path /app/dist
RUN npm run build -- --outputPath=./dist --configuration=${configuration:production}

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx

FROM nginx:1.19.2-alpine

WORKDIR app

# copy (build-stage)/app/dist in /app
COPY --from=build-stage /app/dist/ ./

# overwrite default.confjson with nginx-custom.conf
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf