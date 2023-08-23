FROM node


WORKDIR /app

COPY package*.json ./

RUN npm install

ADD . .

EXPOSE 3000

ENTRYPOINT ["npm", "start"]