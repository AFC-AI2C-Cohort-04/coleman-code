## Cloud Native | Week 6 | Task 1

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/start.md)    Task 1    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_4.md)

---

0a.   go to task1 directory (root folder is specific to your github username)
``` bash
cd task1/
```

0b.   create gateway.yaml
``` bash
GATEWAY_CLASS_NAME=$(kubectl get gatewayclass -o json | jq -r '.items[].metadata.name')
echo -e "apiVersion: gateway.networking.k8s.io/v1beta1\nkind: Gateway\nmetadata:
  name: prod-web\nspec:\n  gatewayClassName: ${GATEWAY_CLASS_NAME}\n  listeners:
  - protocol: HTTP\n    port: 80\n    name: prod-web-gw\n    allowedRoutes:
      namespaces:\n        from: Same" > gateway.yaml
```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)
