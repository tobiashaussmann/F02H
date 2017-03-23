## Creating and Managing Deployments

Deployments sit on top of ReplicaSets and add the ability to define how updates to Pods should be rolled out.

In this section we will combine everything we learned about Pods and Services and create a Deplyoment manifest for our hello-node application. 
* Create a deployment manifest
* Scale our Deployment / ReplicaSet
* Update our application (Rolling Update | Recreate)

----

### Creating Deployments

An example of a deployment is the frontend service of the sock Shops

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hello-node
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: hello-node
    spec:
      containers:
      - name: hello-node
        image: hello-node:v1
        ports:
        - containerPort: 8080
```

----


```
oc create -f configs/deployment-v1.yaml
```

----

### Scaling Deployments

Behind the scenes Deployments manage ReplicaSets. Each deployment is mapped to one active ReplicaSet. Use the `oc get replicasets` command to view the current set of replicas.
```
oc get rs
NAME                   DESIRED   CURRENT   READY     AGE
hello-node-364036756   1         1         1         16s
```
----

### Scaling Deployments

```
oc scale deployments hello-node --replicas=3
deployment "hello-node" scaled
```

----

### Scale down the Deployment

```
oc scale deployments hello-node --replicas=2
deployment "hello-node" scaled
```

----

### Check the status of the Deployment

```
oc describe deployment hello-node
```
```
oc get pods
```

----

### Updating Deployments ( RollingUpdate )

We need to make some changes to our node.js application and create a new image with a new Version. Default update strategy is RollingUpdate and we will test that out first.

Update the text `Hello World!` to something different like `Verion 2`

Build a new Dockerimage and tag it with v2

Push the image to the registry

Update the Deployment
```
oc set image deployments hello-node hello-node=hello-node:v2
```

----

### Validate that it works
We will use curl in a loop to validate that the update will not affect the application.ly` we'll see updates of the pods.

In one terminal
```
for ((i=1;i<=10000;i++)); do curl -s -o /dev/null -I -w "%{http_code}" "0.0.0.0:30080"; done
```
If you want to watch what happens to the pods, open another terminal window and issue:
```
oc get pod --watch-only
```
In another terminal Do a update to the "old" version v1
```
oc set image deployments hello-node hello-node=hello-node:v1
```
You'll see that during the update traffic will get served and no `404` or `500` happend. You also saw the rolling update in the window where you've watched the pod. 

----

### Cleanup

```
oc delete -f configs/deployment-v1.yaml
```
If there were a large number of pods, this may take a while to complete. If you want to leave the pods running instead, specify `--cascade=false`
If you try to delete the pods before deleting the Deployments, it will just replace them, as it is supposed to do.

----

### Updating Deployments ( Recreate )

We'll see how to do an update to our application using the recreate strategy. First we need to create a deploment with the Recreate strategy.
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hello-node
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: hello-node
    spec:
      containers:
      - name: hello-node
        image: hello-node:v1
        ports:
        - containerPort: 8080
```
Create the new Deployment
```
oc create -f configs/deplyoment-v2.yaml
```

Update the Deployment
```
oc set image deployments hello-node hello-node=hello-node:v2
```

----

### Validate that it works
We will use curl in a loop to validate that the update will not affect the application.ly` we'll see updates of the pods.

In one terminal
```
for ((i=1;i<=10000;i++)); do curl -s -o /dev/null -I -w "%{http_code}" "0.0.0.0:30080"; done
```
If you want to watch what happens to the pods, open another terminal window and issue:
```
oc get pod --watch-only
```
In another terminal Do a update to the "old" version v1
```
oc set image deployments hello-node hello-node=hello-node:v1
```
You'll see that curl will stop or even a timeout will occur. You also saw that first all pods are getting terminated befor the new ones are getting started, in the window where you've watched the pod. 

----

### Cleanup

```
oc delete -f configs/deployment-v2.yaml
```

----

### Do it yourself

* Create a deployment manifest for a nginx:1.10 containers with a defined number of replicas=1
* Create a serivce manifest to expose the nginx
* Scale the deployment up to 3
* Validate the scaling was successful
* Update the deployment to use nginx:1.11
* Cleanup