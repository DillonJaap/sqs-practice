package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsapigateway"
	"github.com/aws/aws-cdk-go/awscdk/v2/awslambda"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

func newLambda(scope constructs.Construct, id string, props *awscdk.StackProps) {
	stack := awscdk.NewStack(scope, &id, props)
	cwd, _ := os.Getwd()
	code := fmt.Sprintf("%s/lambda/test_lambda/main.zip", cwd)

	// TODO try to debug this
	handler := awslambda.NewFunction(stack, &id, &awslambda.FunctionProps{
		FunctionName: jsii.String("testLambda"),
		Code: awslambda.Code_FromAsset(
			jsii.String(code),
			nil,
		),
		Handler: jsii.String("main"),
		Runtime: awslambda.Runtime_PROVIDED_AL2(),
	})

	apiGW := awsapigateway.NewRestApi(
		stack,
		jsii.String("rest-api"),
		&awsapigateway.RestApiProps{
			RestApiName: jsii.String("My API Gateway"),
			Description: jsii.String("My API Gateway description"),
		},
	)
	endpoints := apiGW.Root().AddResource(jsii.String("endpoints"), &awsapigateway.ResourceOptions{})
	endpoints.AddMethod(
		jsii.String(http.MethodGet),
		awsapigateway.NewLambdaIntegration(handler, &awsapigateway.LambdaIntegrationOptions{}),
		nil,
	)
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)
	newLambda(app, "SqsPractice", &awscdk.StackProps{
		Env: &awscdk.Environment{
			Account: jsii.String("000000000000"),
			Region:  jsii.String("us-east-1"),
		},
		StackName: jsii.String("SqsPractice"),
	})

	app.Synth(nil)
}
