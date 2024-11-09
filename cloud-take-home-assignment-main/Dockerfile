FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Change ownership of /app to the 'node' user
RUN chown -R node:node /app

# Set the user to the existing 'node' user for the rest of the container lifecycle
USER node

EXPOSE 8000

# Command to run the application
CMD ["node", "src/index.js"]