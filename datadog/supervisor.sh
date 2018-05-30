#!/bin/bash -e

if ! docker ps | grep 'datadog/agent' >/dev/null 2>&1; then
  aws ecs start-task \
    --cluster ${cluster} \
    --task-definition ${datadog_name} \
    --container-instances $$instance_arn \
    --region ${region} \
    >/dev/null 2>&1
fi
