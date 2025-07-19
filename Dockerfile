# Build stage
FROM golang:1.23-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN make build

# Runtime stage
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1000 gorush && \
    adduser -u 1000 -G gorush -D gorush

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/release/gorush /app/gorush

# Change ownership
RUN chown -R gorush:gorush /app

# Switch to non-root user
USER gorush

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/app/gorush", "-ping"]

# Run the application
CMD ["/app/gorush"]