FROM node

WORKDIR /app

COPY package*.json ./

RUN npm install

ADD . .

EXPOSE 3001

CMD ["node", "index.js"]