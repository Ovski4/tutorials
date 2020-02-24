#!/bin/bash

docker events --filter 'event=create'  --filter 'event=start' --filter 'type=container' --format '{{.Actor.Attributes.name}} {{.Status}}' | while read event_info

do
    event_infos=($event_info)
    container_name=${event_infos[0]}
    event=${event_infos[1]}

    echo "$container_name: status = ${event}"

    if [[ $APPLY_TERRAFORM_ON_START == "true" ]] && [[ $container_name = "localstack" ]] && [[ $event == "start" ]]; then
        sleep 20 # let localstack some time to start
        terraform init
        terraform apply --auto-approve
        echo "The terraform configuration has been applied."
        if [[ -n $INVOKE_LAMBDAS_ON_START ]]; then
            echo "Invoking the lambda functions specified in the INVOKE_LAMBDAS_ON_START env variable"
            while IFS=' ' read -ra lambdas; do
                for lambda in "${lambdas[@]}"; do
                    echo "Invoking ${lambda}"
                    aws lambda invoke --function-name ${lambda} --endpoint-url=http://localstack:4574 output.txt &
                done
            done <<< "$INVOKE_LAMBDAS_ON_START"
        fi
    fi
done
