#!/bin/bash
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo;
curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -;
yum -y install yarn;
