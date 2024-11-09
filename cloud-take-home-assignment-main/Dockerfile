FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8000

# Command to run the application
CMD ["node", "src/index.js"]