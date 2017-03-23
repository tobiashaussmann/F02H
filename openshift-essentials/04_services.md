## Creating and Managing Services

In this section you will create the `hello-node` service and "expose" the `hello-node` Pod. You will learn how to:

* Create a service
* Use label and selectors to expose a limited set of Pods externally

----

### Introduction to services
Services provide stable endpoints for Pods based on a set of labels and selectors.
Some of the service types are :
`ClusterIP` Your service is only expose internally to the cluster on the internal cluster IP. A example would be to deploy Hasicorp’s vault and expose it only internally.

`NodePort` Expose the service on the instances on the specified or random assigned port.

`LoadBalancer` Supported on e.g. Amazon and Google cloud, this creates load balancer VIP

`ExternalName` Create a CNAME dns record to a external domain.

For more information about Services look at https://kubernetes.io/docs/user-guide/services/

----

### Create a Service

Explore the hello-node service configuration file:

```
cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-node
spec:
  type: NodePort
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: hello-node
```
type: NodePort is needed as we don't have a integrated loadbalancer like at GKE/AWS
----

Create the hello-node service using oc:

```
oc create -f service.yaml
```

----

### Interact with the hello-node Service Remotely

Find out the NodePort
```
oc describe svc hello-node
Name:			hello-node
Namespace:		training
Labels:			<none>
Selector:		app=hello-node
Type:			NodePort
IP:			172.30.232.225
Port:			<unset>	8080/TCP
NodePort:		<unset>	30080/TCP
Endpoints:		10.128.0.23:8080
Session Affinity:	None
No events.
```
curl -i 0.0.0.0:30080
```

----

### Explore the hello-node Service

```
oc get services hello-node
```

```
oc describe services hello-node
```

----

### Using and adding labels to Pods

One way to troubleshoot an issue is to use the `oc get pods` command with a label query.

```
oc get pods -l "app=hello-node"
```

With the `oc label` command you can add labels like `secure=disabled` to a Pod.

```
oc label pods hello-node 'secure=disabled'
```

----

View the list of endpoints on the `hello-node` service:

```
oc describe services hello-node
```

----

### Do it yourself
* Create a service for the nginx pods
* Expose it using NodePort
* Access the service on that port using `curl`or your browser