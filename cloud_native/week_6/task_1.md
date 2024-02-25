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
kubectl apply -f gateway.yaml
```

0c.   update llm-service/k8s/deployment.yaml, update llm-service/Makefile, make, push, and apply
``` bash
cd ../llm-service/k8s/ && \
acr_name=$(az resource list -g project3 --output json | jq -r '.[] | select(.type == "Microsoft.ContainerRegistry/registries") | .name') && \
sed -i "s/p3acr/${acr_name}/g" deployment.yaml && \
cd ../ && \
sed -i "s/p3acr/${acr_name}/g" Makefile && \
make wheel && make push && kubectl apply -f k8s/
```

0d.   create and apply httproute.yaml in k8s/
``` bash
gateway_ip=$(kubectl get gateway -o json | jq -r '.items[0].status.addresses[0].value')
echo -e "apiVersion: gateway.networking.k8s.io/v1beta1\nkind: HTTPRoute
metadata:\n  name: project3gateway\nspec:\n  parentRefs:
  - name: project3gateway\n    sectionName: project3gateway-http
  - name: project3gateway\n    sectionName: project3gateway-https\n  hostnames:
  - ${gateway_ip}\n  rules:\n  - matches:\n    - path:
        type: PathPrefix\n        value: /\n    backendRefs:
    - name: llmservice\n      port: 80" > httproute.yaml && \
kubectl apply -f httproute.yaml && \
curl http://${gateway_ip}/api?message=hi
```

---

1a.   
``` bash
```

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)
