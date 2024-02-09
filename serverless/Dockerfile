# https://github.com/navarasu/serverless-ruby-layer/blob/master/examples/use-docker-file/Dockerfile
#FROM public.ecr.aws/sam/build-ruby3.2:latest-x86_64
FROM public.ecr.aws/lambda/ruby:3.2
RUN yum install -y amazon-linux-extras \
    && amazon-linux-extras enable postgresql14 \
    && yum group install -y "Development Tools" \
    && yum install -y postgresql-devel
RUN gem update bundler
CMD "/bin/bash"