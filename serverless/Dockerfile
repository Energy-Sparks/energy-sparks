# https://github.com/wildomonges/lambda-ruby3.2-container-image/blob/main/Dockerfile
# FROM amazonlinux:2023
FROM public.ecr.aws/lambda/provided:latest
# FROM public.ecr.aws/sam/build-ruby3.2:latest-x86_64

# Define custom function directory
ARG FUNCTION_DIR="/function"

# Install ruby, bundler and the Runtime Interface Client
# https://docs.aws.amazon.com/linux/al2023/release-notes/all-packages-AL2023.3.html
RUN dnf install -y ruby ruby-devel ruby3.2-rubygem-bundler libpq-devel git make gcc g++ \
  && dnf clean all \
  && gem install aws_lambda_ric

# Set working directory
WORKDIR ${FUNCTION_DIR}

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ${FUNCTION_DIR}/
RUN bundle config set --local deployment true && bundle config set --local without 'test development web' \
  && bundle install

# Copy layer codes
ADD config ./config
ADD lib ./lib
ADD app ./app

# Copy lambda function code
COPY serverless/handler.rb ${FUNCTION_DIR}/

# Call lambda runtime
ENTRYPOINT ["/usr/local/bin/aws_lambda_ric"]
# ENTRYPOINT ["/bin/bash", "-l", "-c"]

#CMD ["app.lambda_handler"]
