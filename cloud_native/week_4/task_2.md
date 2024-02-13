## Cloud Native | Week 4 | Task 2

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_1.md)    Task 2    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_4.md)

---

0a.   create k8s cluster
``` bash
az aks create \
  --resource-group project2task1 \
  --name project2cluster \
  --enable-managed-identity \
  --node-count 3 \
  --generate-ssh-keys
```

0b.   connect acr to cluster
``` bash
az aks update \
  --resource-group project2task1 \
  --name project2cluster \
  --attach-acr $acr_name \
  --enable-vpa && \
az aks get-credentials \
  --resource-group project2task1 \
  --name project2cluster && \
kubectl get nodes
```

---

1a.   make kubernetes directory for task 2 and create deployment.yaml
``` bash
mkdir ~/llmservice-handout/worker/task2/
cd ~/llmservice-handout/worker/task2/
acr_name=$(az resource list -g project2task1 --output json | jq -r '.[] | select(.type == "Microsoft.ContainerRegistry/registries") | .name')
arc_server=$acr_name.azurecr.io
container_name=simplellm:latest
echo -e "apiVersion: apps/v1\nkind: Deployment\nmetadata:
  name: simplellm-deployment\n  annotations:
    goldilocks.fairwinds.com/enabled: \"true\"\nspec:\n  replicas: 1\n  selector:
    matchLabels:\n      app: simplellm\n  template:\n    metadata:
      labels:\n        app: simplellm\n    spec:\n      containers:
      - name: simplellm\n        image: ${acr_server}/${container_name}
        ports:\n        - containerPort: 8080" > deployment.yaml
```

1b.   create service.yaml
``` bash
cd ~/llmservice-handout/worker/task2/
echo -e "apiVersion: v1\nkind: Service\nmetadata:\n  name: simplellm-service
spec:\n  selector:\n    app: simplellm\n  ports:\n  - port: 80
    targetPort: 8080\n  type: LoadBalancer" > service.yaml
```

1c.   create vpa.yaml (vertical pod autoscaler)
``` bash
cd ~/llmservice-handout/worker/task2/
echo -e "apiVersion: autoscaling.k8s.io/v1\nkind: VerticalPodAutoscaler
metadata:\n  name: simplellm-vpa\nspec:\n  targetRef:\n    apiVersion: apps/v1
    kind: Deployment\n    name: simplellm-deployment\n  updatePolicy:
    updateMode: Auto" > vpa.yaml
```

---

2a.   
``` bash
cd ~/llmservice-handout/worker/task2/
kubectl apply -f .
```

2b.   
``` bash
LOAD_BALANCER_EXTERNAL_IP=$(kubectl get service simplellm-service --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$LOAD_BALANCER_EXTERNAL_IP:80/healthcheck
```

*.   (troubleshooting steps / commands)
```
# list all services in the default namespace (ensure load balancer external ip exists)
kubectl get services

# remove service
kubectl delete service <service-nane>

# list all pods in the default namespace
kubectl get pods

# retrieve the logs for a specific pod
kubectl logs <POD_NAME>

# exec command will give you the terminal access inside of the pod
kubectl exec -it <POD_NAME> -- /bin/sh

---

[<< Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_1.md)    [Task 3 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_3.md)
