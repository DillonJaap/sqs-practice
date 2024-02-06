package main

import "github.com/aws/aws-lambda-go/lambda"

type testInput struct {
	id      int
	name    string
	message string
}

type testOutput struct {
	id      int
	name    string
	message string
}

func main() {
	lambda.Start(
		func(in testInput) (testOutput, error) {
			return testOutput{
				id:      777,
				name:    "test",
				message: "msg",
			}, nil
		},
	)
}
