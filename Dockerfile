# Build Stage
FROM node:lts-buster as build
RUN apt-get update && apt-get install -y ca-certificates

WORKDIR /build
COPY package*.json ./

# Include dev dependencies since Vite is used for building
RUN npm ci

# Build the app
COPY . .
RUN npm run build

# Production Stage
FROM node:lts-buster-slim
WORKDIR /app

# Copy all files since they are in the same directory
COPY --from=build /build/dist ./

# Copy the package lock file
COPY --from=build /build/package*.json ./ 
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Install production dependencies only
RUN npm ci --omit=dev

# Install ONLY production dependencies
ENV NODE_ENV=production

EXPOSE 5173

# Start the server
CMD ["npm", "run", "preview" || "npm", "run", "build" && "npm", "run", "preview"]  # With error handling
#CMD ["node", "src/server/main.ts"]  # Use the correct path to main.ts
