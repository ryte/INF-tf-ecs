#!/bin/bash +ex

cd /tmp
sudo yum install -y gcc
wget http://download.redis.io/redis-stable.tar.gz && tar xvzf redis-stable.tar.gz && cd redis-stable && make && sudo cp src/redis-cli /usr/bin/ && sudo chmod 755 /usr/bin/redis-cli


sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo start amazon-ssm-agent

# see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html
cat << EOF > /etc/ecs/ecs.config
ECS_CLUSTER=${cluster_name}
ECS_RESERVED_MEMORY=64
${ecs_engine_auth_type}
${list_of_registries}
EOF
