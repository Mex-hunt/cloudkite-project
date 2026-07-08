FROM node:22-alpine AS build

ARG VITE_API_BASE_URL=http://localhost:8000
ARG VITE_APP_VERSION=0.1.0
ARG VITE_ENVIRONMENT=local
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL \
    VITE_APP_VERSION=$VITE_APP_VERSION \
    VITE_ENVIRONMENT=$VITE_ENVIRONMENT

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
