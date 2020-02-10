FROM docker:19.03.5

RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash wget unzip

# Install AWS CLI
RUN echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing' > /etc/apk/repositories && \
    wget "s3.amazonaws.com/aws-cli/awscli-bundle.zip" -O "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    apk add --update groff less python curl && \
    rm /var/cache/apk/* && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    rm awscli-bundle.zip && \
    rm -rf awscli-bundle
COPY aws_credentials.txt /root/.aws/credentials
COPY aws_config.txt /root/.aws/config

# Install terraform
RUN wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip \
  && unzip terraform_0.12.20_linux_amd64 \
  && mv terraform /usr/local/bin/terraform \
  && chmod +x /usr/local/bin/terraform

RUN mkdir -p /opt/terraform
WORKDIR /opt/terraform

COPY listen-docker-events.sh /var/listen-docker-events.sh

CMD ["/bin/bash", "/var/listen-docker-events.sh"]
