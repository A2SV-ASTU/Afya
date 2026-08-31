# AfyaMind Backend Makefile

.PHONY: swagger dev build test

## swagger: Regenerate Swagger docs from annotations (requires swag CLI)
##          Install: go install github.com/swaggo/swag/cmd/swag@latest
swagger:
	swag init -g cmd/api/main.go --output docs --parseDependency --parseInternal

## dev: Regenerate Swagger docs then run the dev server
dev: swagger
	go run ./cmd/api/main.go

## build: Build the API binary
build:
	go build -o api.exe ./cmd/api/main.go

## test: Run all tests
test:
	go test ./...
