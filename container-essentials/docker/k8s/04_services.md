## Creating and Managing Services

Services provide stable endpoints for Pods based on a set of labels and selectors.

In this section you will create the `k8s-hello-world` service and "expose" the `k8s-hello-world` Pod. You will learn how to:

* Create a service
* Use label and selectors to expose a limited set of Pods externally

----

### Create a Service

Explore the k8s-hello-world service configuration file:

```
cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: k8s-hello-world
spec:
  type: NodePort
  ports:
    - port: 8080
    protocol: TCP
    targetPort: 8080
    nodePort: 30080
  selector:
    app: k8s-hello-world
```
type: NodePort is needed as we don't have a integrated loadbalancer like at GKE/AWS
nodePort: We assigned a static high-port for having consistency in this doc. If not statically set, a random port between 30000-32000 will be assigned.
----

Create the k8s-hello-world service using kubectl:

```
kubectl create -f service.yaml
```

----

### Interact with the k8s-hello-world Service Remotely

```
curl -i 0.0.0.0:30080
```

----

### Explore the k8s-hello-world Service

```
kubectl get services k8s-hello-world
```

```
kubectl describe services k8s-hello-world
```

----

### Using and adding labels to Pods

One way to troubleshoot an issue is to use the `kubectl get pods` command with a label query.

```
kubectl get pods -l "app=k8s-hello-world"
```

With the `kubectl label` command you can add labels like `secure=disabled` to a Pod.

```
kubectl label pods k8s-hello-world 'secure=disabled'
```

----

View the list of endpoints on the `k8s-hello-world` service:

```
kubectl describe services k8s-hello-world
```

----

### Do it yourself
* Create a service for the nginx pods
* Expose port 80 to a static nodePort 31000
* Access the service on port 31000 using `curl`or your browser