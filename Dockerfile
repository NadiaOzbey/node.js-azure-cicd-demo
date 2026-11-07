# Use Node.js 24 as the base image
FROM node:24-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (no development, only production)
RUN npm ci --omit=dev

# Copy application source code
COPY src ./src

# Expose application port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]