Replicate AWS in local with localstack
======================================

An example on how to use localstack to mock AWS services. The following instructions focus on how to run localstack and deploy:
* a dynamodb table
* a lambda reading data and putting data to this table

Usage
-----

Run

```bash
git clone https://github.com/Ovski4/tutorials.git
cd localstack-part-1
docker network create localstack-tutorial
docker-compose up -d
docker-compose logs -f localstack
```

Wait for set up to be done, then create a dynamodb table:

```bash
aws dynamodb create-table \
  --endpoint-url http://localhost:4569 \
  --table-name table_1 \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20
```

To check if the table was properly created, run:

```bash
aws dynamodb list-tables --endpoint-url http://localhost:4569
```

Create and deploy the lambda function:

```bash
cd lambda
zip -r ../lambda.zip .
cd ..
aws lambda create-function \
  --function-name counter \
  --runtime nodejs8.10 \
  --role fake_role \
  --handler main.handler \
  --endpoint-url http://localhost:4574 \
  --zip-file fileb://$PWD/lambda.zip
```

Invoke the function multiple times and scan the table to see new items and their counters being incremented:

```bash
aws lambda invoke --function-name counter --endpoint-url=http://localhost:4574 --payload '{"id": "test"}' output.txt
aws dynamodb scan --endpoint-url http://localhost:4569 --table-name table_1

aws lambda invoke --function-name counter --endpoint-url=http://localhost:4574 --payload '{"id": "test2"}' output.txt
aws dynamodb scan --endpoint-url http://localhost:4569 --table-name table_1
```