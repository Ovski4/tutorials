FROM localstack/localstack:0.10.7

# Update localstack code to prevent the destruction of the lambda containers every 10 minutes
COPY localstack.patch /opt/code/localstack/localstack.patch
RUN apk add git && git apply localstack.patch && apk del --purge git
