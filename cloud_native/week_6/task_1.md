## Cloud Native | Week 6 | Task 1

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/start.md)    Task 1    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_4.md)

---

0a.   go to task1 directory (root folder is specific to your github username)
``` bash
cd task1/
```

0b.   create gateway.yaml
``` bash
GATEWAY_CLASS_NAME=$(kubectl get gatewayclass -o json | jq -r '.items[].metadata.name') && \
echo -e "apiVersion: gateway.networking.k8s.io/v1beta1\nkind: Gateway\nmetadata:
  name: prod-web\nspec:\n  gatewayClassName: ${GATEWAY_CLASS_NAME}\n  listeners:
  - protocol: HTTP\n    port: 80\n    name: prod-web-gw\n    allowedRoutes:
      namespaces:\n        from: Same" > gateway.yaml
```

0c.   create deployment.yaml (incomplete)
``` bash
acr_name=$(az resource list -g project3 --output json | jq -r '.[] | select(.type == "Microsoft.ContainerRegistry/registries") | .name') && \
acr_server=$acr_name.azurecr.io
container_name=simplellm:v1.0.0
echo -e "apiVersion: apps/v1\nkind: Deployment\nmetadata:
  name: simplellm-deployment\n  annotations:
    goldilocks.fairwinds.com/enabled: \"true\"\nspec:\n  replicas: 1\n  selector:
    matchLabels:\n      app: simplellm\n  template:\n    metadata:
      labels:\n        app: simplellm\n    spec:\n      containers:
      - name: simplellm\n        image: ${acr_server}/${container_name}
        ports:\n        - containerPort: 8080
        resources:\n          requests:\n            cpu: \"200m\"
            memory: \"263M\"\n          limits:\n            cpu: \"200m\"
            memory: \"263M\"" > deployment.yaml
```

0d.   create service.yaml (incomplete)
``` bash
echo -e "apiVersion: v1\nkind: Service\nmetadata:\n  name: simplellm-service
spec:\n  selector:\n    app: simplellm\n  ports:\n  - port: 80
    targetPort: 8080\n  type: LoadBalancer" > service.yaml
```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)
