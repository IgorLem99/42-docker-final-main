# use multi- stage build 
FROM golang:1.21 AS builder


WORKDIR /app


COPY go.mod go.sum ./
RUN go mod download

COPY . .
# name tracker
RUN go build -o tracker main.go


# 2 use light image debian
FROM debian:bullseye-slim

# install tx data for timetrack and clear cache 
RUN apt-get update && apt-get install -y tzdata && apt-get clean && \
    mkdir /app && rm -rf /var/lib/apt/lists/*

# set dir
WORKDIR /app

# copy from prebuild
COPY --from=builder /app/tracker .
COPY tracker.db .

# Port
EXPOSE 8080

# Start
CMD ["./tracker"]
