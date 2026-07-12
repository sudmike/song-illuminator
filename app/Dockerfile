FROM mirror.gcr.io/library/node:24-alpine AS frontend
WORKDIR /build/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM mirror.gcr.io/library/golang:1.26-alpine AS backend
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
COPY --from=frontend /build/frontend/dist ./frontend/dist
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /song-illuminator ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=backend /song-illuminator ./song-illuminator
COPY --from=frontend /build/frontend/dist ./frontend/dist
ENV APP_ENV=production PORT=8080 STATIC_DIR=/app/frontend/dist
EXPOSE 8080
ENTRYPOINT ["/app/song-illuminator"]
