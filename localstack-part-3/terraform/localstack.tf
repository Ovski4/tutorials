terraform {
  required_providers {
    aws = "~> 2.39.0"
  }
}

provider "aws" {
  region                      = "ap-southeast-2"
  access_key                  = "fake"
  secret_key                  = "fake"

  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    dynamodb = "http://localstack:4569"
    lambda   = "http://localstack:4574"
  }
}

resource "aws_dynamodb_table" "table_1" {
  name           = "table_1"
  read_capacity  = "20"
  write_capacity = "20"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_lambda_function" "counter" {
  function_name = "counter"
  filename      = "lambda.zip"
  role          = "fake_role"
  handler       = "main.handler"
  runtime       = "nodejs8.10"
  timeout       = 30
}
