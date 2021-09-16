#!/bin/bash +ex

# see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
iptables --insert FORWARD 1 --in-interface docker+ --destination 169.254.169.254/32 --jump DROP
service iptables save

# see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html
yum install -y awslogs jq

cluster=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .Cluster')
container_instance_id=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $2}' )

cat << EOF > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${cluster_name}
log_stream_name = $cluster/var/log/dmesg/$container_instance_id

[/var/log/messages]
file = /var/log/messages
log_group_name = ${cluster_name}
log_stream_name = $cluster/var/log/messages/$container_instance_id
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${cluster_name}
log_stream_name = $cluster/var/log/docker/$container_instance_id
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log
log_group_name = ${cluster_name}
log_stream_name = $cluster/var/log/ecs/ecs-init.log/$container_instance_id
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = ${cluster_name}
log_stream_name = $cluster/var/log/ecs/ecs-agent.log/$container_instance_id
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = ${cluster_name}
log_stream_name = $cluster/var/log/ecs/audit.log/$container_instance_id
datetime_format = %Y-%m-%dT%H:%M:%SZ
EOF

# overwrite AWS CloudWatch Logs location
sed -i "s/region = us-east-1/region = ${aws_region}/" /etc/awslogs/awscli.conf
service awslogs restart

touch /tmp/setup-$(date "+%Y%m%d%H%M%S")
