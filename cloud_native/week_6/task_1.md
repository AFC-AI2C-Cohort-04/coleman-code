## Cloud Native | Week 6 | Task 1

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/start.md)    Task 1    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_4.md)

---

### subtask 1: create a gateway resource

1a.   go to task1 directory (root folder is specific to your github username)
``` bash
cd task1/
```

1b.   create gateway.yaml
``` bash
GATEWAY_CLASS_NAME=$(kubectl get gatewayclass -o json | jq -r '.items[].metadata.name') && \
echo -e "apiVersion: gateway.networking.k8s.io/v1beta1\nkind: Gateway\nmetadata:
  name: project3gateway\nspec:\n  gatewayClassName: ${GATEWAY_CLASS_NAME}
  listeners:\n  - name: project3gateway-http\n    protocol: HTTP\n    port: 80
    allowedRoutes:\n      namespaces:\n        from: Same" > gateway.yaml && \
kubectl apply -f gateway.yaml
```

1c.   update llm-service/k8s/deployment.yaml, update llm-service/Makefile, make, push, and apply
``` bash
cd ../llm-service/k8s/ && \
acr_name=$(az resource list -g project3 --output json | jq -r '.[] | select(.type == "Microsoft.ContainerRegistry/registries") | .name') && \
sed -i "s/p3acr/${acr_name}/g" deployment.yaml && \
cd ../ && \
sed -i "s/p3acr/${acr_name}/g" Makefile && \
make wheel && make push && kubectl apply -f k8s/
```

*a.   validation (opens sub-shell)
``` bash
llm_cluster_ip=$(kubectl get svc llmservice -o json | jq -r '.spec.clusterIP') && \
echo "curl ${llm_cluster_ip}/api?message=hi" && \
kubectl run curlpod --image=radial/busyboxplus:curl -i --tty --rm
```

*b.   validation
``` bash
# run 'curl <llm_cluster_ip>/api?message=hi' and wait for json response
exit
```

---

### subtask 2: create your first httproute

2.   create and apply httproute.yaml in k8s/
``` bash
gateway_ip=$(kubectl get gateway -o json | jq -r '.items[0].status.addresses[0].value') && \
echo -e "apiVersion: gateway.networking.k8s.io/v1beta1\nkind: HTTPRoute
metadata:\n  name: project3gateway\nspec:\n  parentRefs:
  - name: project3gateway\n    sectionName: project3gateway-http
  - name: project3gateway\n    sectionName: project3gateway-https\n  rules:
  - matches:\n    - path:\n        type: PathPrefix\n        value: /
    backendRefs:\n    - name: llmservice\n      port: 80" > httproute.yaml && \
kubectl apply -f httproute.yaml
```

*.   validation
``` bash
curl ${gateway_ip}/api?message=hi
```

---

### subtask 3: securing and productionizing your gateway

3a.   go to [noip.com](noip.com), create free account and setup a DNS for <acr_name>.zapto.org, use gateway ip as the target ip (type A)

3b.   update httproute.yaml in k8s/ with dns hostname
``` bash
sed -i "s/rules:/  hostnames:\n  - ${acr_name}.zapto.org\n  rules:/g" httproute.yaml && \
kubectl apply -f httproute.yaml
```

*.   validation
``` bash
curl http://${acr_name}.zapto.org/api?message=hi
```

---

### subtask 4: ssl certs

4a.   install cert manager
``` bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.0 \
  --set installCRDs=true \
  --set "extraArgs={--feature-gates=ExperimentalGatewayAPISupport=true}"
```

4b.   create clusterissuer.yaml in k8s/ (update with your email)
``` bash
################################################################################
echo -e "apiVersion: cert-manager.io/v1\nkind: ClusterIssuer\nmetadata:
  name: letsencrypt\nspec:\n  acme:\n    email: <email@domain>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:\n      name: issuer-account-key\n    solvers:
    - http01:\n        gatewayHTTPRoute:\n          parentRefs:
          - name: project3gateway
            kind: Gateway" > clusterissuer.yaml && \
kubectl apply -f clusterissuer.yaml && \
kubectl describe clusterissuer
```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)
