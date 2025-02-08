FROM ubuntu:24.10

# https://jekyllrb.com/docs/installation/ubuntu/

RUN apt-get update && apt-get install -y ruby-full build-essential zlib1g-dev

VOLUME /root/gems

ENV BUNDLE_PATH=/root/gems
ENV GEM_HOME=/root/gems
ENV GEM_PATH=/root/gems
ENV PATH="/root/gems/bin:$PATH"

RUN gem install jekyll bundler

WORKDIR /var
