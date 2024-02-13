## Cloud Native | Week 4 | Task 3

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)    Task 3    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_4.md)

---

0a.   login to acr
``` bash
acr_name=$(az resource list -g project2task1 --output json | jq -r '.[] | select(.type == "Microsoft.ContainerRegistry/registries") | .name') && \
az acr update \
  --name $acr_name \
  --admin-enabled true && \
az acr login \
  --name $acr_name
```

0b.   delete vpa
``` bash
kubectl delete vpa simplellm-vpa && \
cd ~/llmservice-handout/worker/task2/
rm vpa.yaml
mv ~/llmservice-handout/worker/task2/ ~/llmservice-handout/worker/task3/
cd ~/llmservice-handout/worker/task3/
```

0c.   update deployment.yaml
```
cd ~/llmservice-handout/worker/task3/
echo -e "apiVersion: apps/v1\nkind: Deployment\nmetadata:
  name: simplellm-deployment\n  annotations:
    goldilocks.fairwinds.com/enabled: \"true\"\nspec:\n  replicas: 1
  selector:\n    matchLabels:\n      app: simplellm\n  template:\n    metadata:
      labels:\n        app: simplellm\n    spec:\n      containers:
      - name: simplellm\n        image: acre74498ea.azurecr.io/simplellm:v1.0.0
        ports:\n        - containerPort: 8080\n        resources:
          requests:\n            cpu: \"200m\"\n            memory: \"263M\"
          limits:\n            cpu: \"200m\"\n            memory: \"263M\"
        readinessProbe:\n          periodSeconds: 3
          failureThreshold: 1\n          httpGet:
            path: /healthcheck\n            port: 8080\n        startupProbe:
          periodSeconds: 5\n          failureThreshold: 5\n          httpGet:
            path: /healthcheck\n            port: 8080" > deployment.yaml
```

0d.   create hpa.yaml
``` bash
cd ~/llmservice-handout/worker/task3/
echo -e "apiVersion: autoscaling/v2\nkind: HorizontalPodAutoscaler\nmetadata:
  name: simplellm-hpa\nspec:\n  scaleTargetRef:\n    apiVersion: apps/v1
    kind: Deployment\n    name: simplellm-deployment\n  minReplicas: 1
  maxReplicas: 4\n  behavior:\n    scaleUp:\n      policies:\n      - type: Pods
        value: 1\n        periodSeconds: 10\n    scaleDown:\n      policies:
      - type: Pods\n        value: 1\n        periodSeconds: 10\n  metrics:
  - type: Resource\n    resource:\n      name: cpu\n      target:
        type: Utilization\n        averageUtilization: 50" > hpa.yaml
```

---

1a.   apply kubectl scheme
``` bash
cd ~/llmservice-handout/worker/task3/
kubectl -n default apply -f .
```

1b.   loadtest
``` bash
cd ~/llmservice-handout/worker/loadtester/
locust --headless -H http://$(kubectl -n default get svc simplellm-service -o json | jq -r '.status.loadBalancer.ingress[0].ip') -u 3 -r 1
```

---

2.   submit
``` bash
cd ~/llmservice-handout/
./submitter task3
```

---

[<< Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)    [Task 4 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_4.md)
