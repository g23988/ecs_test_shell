#!/bin/sh
sudo yum install -y ecs-init
sudo service docker start
sudo start ecs
curl http://`curl http://169.254.169.254/2018-08-17/meta-data/public-ipv4`:51678/v1/metadata

## close default docker
sudo stop ecs
sudo docker rm -f ecs-agent 

## configure ecs.config to clustor
sudo mkdir -p /etc/ecs && sudo touch /etc/ecs/ecs.config
echo "ECS_DATADIR=/data" > /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE=true" > /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true" > /etc/ecs/ecs.config
echo "ECS_LOGFILE=/log/ecs-agent.log" > /etc/ecs/ecs.config
echo 'ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]' > /etc/ecs/ecs.config
echo "ECS_LOGLEVEL=info" > /etc/ecs/ecs.config
echo "ECS_CLUSTER=test" > /etc/ecs/ecs.config

sudo mkdir -p /var/log/ecs /var/lib/ecs/data

sudo docker run --name ecs-agent \
--detach=true \
--restart=on-failure:10 \
--volume=/var/run:/var/run \
--volume=/var/log/ecs/:/log \
--volume=/var/lib/ecs/data:/data \
--volume=/etc/ecs:/etc/ecs \
--net=host \
--env-file=/etc/ecs/ecs.config \
amazon/amazon-ecs-agent:latest
