# Build Stage
FROM node:lts-buster as build

WORKDIR /build
COPY package*.json ./

# Include dev dependencies since Vite is used for building
RUN npm ci

# Build the app
COPY . .
RUN npm run build

# Production Stage
FROM node:lts-buster
WORKDIR /app/build

# Copy all files since they are in the same directory
COPY --from=build /build/build ./
# Install ONLY production dependencies
RUN npm ci --only=production

EXPOSE 5173

# Start the server
CMD ["npm", "run", "preview" || "npm", "run", "build" && "npm", "run", "preview"]  # With error handling
#CMD ["node", "src/server/main.ts"]  # Use the correct path to main.ts
