# ======================
# Stage 1: build
# ======================

FROM gcr.io/google-appengine/golang:1.18 AS builder

# RUN apt-get update && apt-get install -y git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o auth-api .


# ======================
# Stage 2: runtime
# ======================

FROM gcr.io/distroless/base-debian11

# RUN apk --no-cache add ca-certificates

COPY --from=builder /app/auth-api /auth-api

EXPOSE 8000

ENV AUTH_API_PORT=8000
ENV USERS_API_ADDRESS=http://127.0.0.1:8083

ENTRYPOINT ["/auth-api"]
