COVERAGE_FILE = "coverage.out"
LOCALSTACK_REGION = "us-east-1"
LOCALSTACK_ACCOUNT = "000000000000"
LOCALSTACK_WORKSPACE = "test"
JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION = "true"


# Ignore `No rule to make target` errors
%:
	@echo ""

# Install vendor dependencies
.PHONY: deps
deps:
	@echo "installing dependencies"
	@go mod download
	@go mod vendor

# Run unit tests
.PHONY: test
test: deps
	go test -count=1 -race -coverprofile=${COVERAGE_FILE} ./...

.PHONY: integration
integration: deps deploy-ls
	go test -tags='integration' -v ./integration

# Generate coverage report
.PHONY: report
report:
	@go tool cover -html=${COVERAGE_FILE}

# Build the lambdas for a localstack environment.
.PHONY: build
build: deps
	@(cd cdk && go build)
	for dir in ./lambda/*; do \
		name=$$(basename $$dir) ; \
		echo "Building lambda: $$name" ; \
		( \
			cd $$dir && \
			GOOS=linux go build -o bootstrap && \
			zip -q main.zip bootstrap && \
			rm bootstrap \
		) \
	done ; \


# Build the lambdas for a localstack environment.
.PHONY: build-ls
build-ls: start-ls
	@(cd cdk && go build) & \
	for dir in ./lambda/*; do \
		name=$$(basename $$dir) ; \
		echo "Building lambda: $$name" ; \
		( \
			cd $$dir && \
			GOOS=linux go build -tags localstack -o bootstrap && \
			zip -0q main.zip bootstrap && \
			rm bootstrap \
		) & \
	done ; \
	wait

# deploy the stack to localstack. Assumes `cdklocal` is installed
.PHONY: deploy-ls
deploy-ls:
	export REGION=${LOCALSTACK_REGION} ; \
	export ACCOUNT=${LOCALSTACK_ACCOUNT} ; \
	export WORKSPACE=${LOCALSTACK_WORKSPACE} ; \
	export JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION=${JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION} ; \
	export DD_API_KEY=test ; \
	export VERSION=1 ; \
	cdklocal bootstrap && \
	cdklocal deploy --build "make build-ls" --outputs-file ./integration/cdk-outputs.json
