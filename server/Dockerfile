FROM node:18
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . .
RUN yarn install
RUN yarn run build

EXPOSE 3000
CMD ["yarn", "start:dev"]