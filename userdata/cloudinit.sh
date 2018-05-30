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

if [ ${datadog_enable} -eq 1 ]; then
  # this needs some time until it's possible to curl
  start ecs
  sudo yum install -y aws-cli jq
  mkdir -p ${datadog_log_pointer_dir}
  instance_arn=$(curl -f http://localhost:51678/v1/metadata \
    | jq -re .ContainerInstanceArn | awk -F/ '{print $NF}')

  cat << EOF > /usr/sbin/${datadog_supervisor}
${datadog_supervisor_script}
EOF
  chmod +x /usr/sbin/${datadog_supervisor}
  cat << EOF > /etc/cron.d/${datadog_supervisor}
${datadog_supervisor_cron}
EOF
  service crond restart
fi
