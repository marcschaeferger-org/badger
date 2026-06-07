YAEGI_VERSION ?= v0.16.1
GOVULNCHECK_VERSION ?= v1.3.0

.PHONY: fmt tidy vet lint test vulncheck yaegi-test ci

fmt:
	gofmt -w .

tidy:
	go mod tidy

vet:
	go vet ./...

lint:
	golangci-lint run

test:
	go test -race -cover ./...

vulncheck:
	go install golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION)
	govulncheck ./...

# Traefik interprets the plugin with Yaegi at runtime. Yaegi's "test" command
# takes a single package, so this targets the root plugin package (".").
yaegi-test:
	go run github.com/traefik/yaegi/cmd/yaegi@$(YAEGI_VERSION) test -v .

# Reproduce the CI checks locally.
ci:
	test -z "$$(gofmt -l .)"
	go mod tidy
	git diff --exit-code -- go.mod go.sum
	go vet ./...
	go test -race -cover ./...
	go install golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION)
	govulncheck ./...
	go run github.com/traefik/yaegi/cmd/yaegi@$(YAEGI_VERSION) test -v .
