## Creating and managing pods

At the core of Kubernetes is the Pod. Pods represent a logical application and hold a collection of one or more containers and volumes. In this lab you will learn how to:

* Write a Pod configuration file
* Create and inspect Pods
* Interact with Pods remotely using kubectl

We'll create a Pod named `k8s-hello-world` and interact with it using the kubectl.

----

### Creating Pods

Explore the `k8s-hello-world` pod configuration file:

```
cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: k8s-hello-world
  labels:
    app: k8s-hello-world
spec:
  containers:
    - name: k8s-hello-world
      image: muellermich/nodejs-hello
      ports:
        - containerPort: 8080
```
Create the pod using kubectl:

```
kubectl create -f pod.yaml
```

----

### View Pod details

Use the `kubectl get` and `kubect describe` commands to view details for the `k8s-hello-world` Pod:

```
kubectl get pods
```

```
kubectl describe pods <pod-name>
```

----

### Interact with a Pod remotely

Pods are allocated a private IP address by default and cannot be reached outside of the cluster. Use the `kubectl port-forward` command to map a local port to a port inside the `k8s-hello-world` pod.

Use two terminals. One to run the `kubectl port-forward` command, and the other to issue `curl` commands.

----

### Do it yourself
* Configure `port-forward``
* Get output of the application using `cur`or your browser

----

### View the logs of a Pod

Use the `kubectl logs` command to view the logs for the `k8s-hello-world` Pod:

```
kubectl logs k8s-hello-world
```

> Use the -f flag and observe what happens.

----

### Run an interactive shell inside a Pod

Like with Docker you can establish an interactive shell to a pod with almost the same sytax. Use the `kubectl exec` command to run an interactive shell inside the `k8s-hello-world` Pod:

```
kubectl exec -ti k8s-hello-world /bin/sh
```

----

### Do it yourself
* Create a Pod manifest using the nginx containers
* Access the pod on port 80 using port-forward
* View the logs of the nginx container
