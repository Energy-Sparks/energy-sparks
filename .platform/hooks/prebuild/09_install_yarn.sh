#!/bin/bash
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo;
yum install https://rpm.nodesource.com/pub_16.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
yum -y install yarn;
