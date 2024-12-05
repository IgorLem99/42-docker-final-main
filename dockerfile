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

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем базу данных и бинарный файл из билд-образа
COPY --from=builder /app/tracker .
COPY tracker.db .

# Указываем порт, который использует приложение (при необходимости)
EXPOSE 8080

# Запуск приложения
CMD ["./tracker"]
