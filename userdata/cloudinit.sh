#!/bin/bash +ex

sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo start amazon-ssm-agent

# see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html
cat << EOF > /etc/ecs/ecs.config
ECS_CLUSTER=${cluster_name}
ECS_RESERVED_MEMORY=64
ECS_ENABLE_CONTAINER_METADATA=true
${ecs_engine_auth_type}
${list_of_registries}
EOF

if [ ${datadog_enable} -eq 1 ]; then
  mkdir -p ${datadog_log_pointer_dir}
fi
