Deploy AWS resources in localstack with Terraform
=================================================

An example on how to use docker events to automatically deploy localstack resources that mock AWS services. The following instructions focus on how to deploy:
* a dynamodb table
* a lambda reading data and putting data to this table

Usage
-----

Run

```bash
docker network create localstack-tutorial
docker-compose up -d
docker-compose logs -f localstack
```

Wait for the resources to be deployed, then invoke the lambda multiple times and scan the table to see new items and their counters being incremented:

```bash
aws lambda invoke --function-name counter --endpoint-url=http://localhost:4574 --payload '{"id": "test"}' output.txt
aws dynamodb scan --endpoint-url http://localhost:4569 --table-name table_1

aws lambda invoke --function-name counter --endpoint-url=http://localhost:4574 --payload '{"id": "test2"}' output.txt
aws dynamodb scan --endpoint-url http://localhost:4569 --table-name table_1
```