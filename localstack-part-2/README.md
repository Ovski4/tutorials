Deploy AWS resources in localstack with Terraform
=================================================

An example on how to use Terraform to deploy localstack resources that mock AWS services. The following instructions focus on how to deploy:
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

Create the lambda:

```bash
cd lambda
zip -r ../lambda.zip .
cd ..
```

Wait for set up to be done, then apply the Terraform configuration:

```bash
git clone https://github.com/Ovski4/tutorials.git
cd localstack-part-2
terraform init
terraform plan
terraform apply --auto-approve
```

Invoke the lambda multiple times and scan the table to see new items and their counters being incremented:

```bash
aws lambda invoke --function-name counter --endpoint-url=http://localhost:4574 --payload '{"id": "test"}' output.txt
aws dynamodb scan --endpoint-url http://localhost:4569 --table-name table_1

aws lambda invoke --function-name counter --endpoint-url=http://localhost:4574 --payload '{"id": "test2"}' output.txt
aws dynamodb scan --endpoint-url http://localhost:4569 --table-name table_1
```