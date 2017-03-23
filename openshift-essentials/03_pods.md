## Creating and managing pods

At the core of OpenShift is the Pod. Pods represent a logical application and hold a collection of one or more containers and volumes. In this lab you will:

* Create a simple Hello World node.js application
* Create a docker container image
* Write a Pod configuration file
* Create and inspect Pods
* Interact with Pods remotely using oc

We'll create a Pod named `hello-world` and interact with it using the oc.

----

### Create your node.js app

A simple “hello world”: server.js (note the port number argument to www.listen):
```
var http = require('http');
var handleRequest = function(request, response) {
  response.writeHead(200);
  response.end("Hello World!");
}
var www = http.createServer(handleRequest);
www.listen(8080);
```
Save that to a file called `server.js`
----

### Create a docker container image

Create the file `Dockerfile` for hello-node (note port 8080 in the EXPOSE command):
```
FROM node:6.9
EXPOSE 8080
COPY server.js /
ENTRYPOINT ["node", "/server.js"]
```

----

### Locate the Image Registry

```
oc logout
oc login -u system:admin
oc get svc
oc get svc
NAME               CLUSTER-IP      EXTERNAL-IP   PORT(S)                   AGE
docker-registry    172.30.6.185    <none>        5000/TCP                  2h
```

----

### Build the container

Use the IP of the registry as usernamespace for the image

```
docker build -t 172.30.6.185:5000/<LASTNAME>/hello-node:v1 .
```

----

### Get access token of the user to login to the registry

```
oc login
oc whoami -t
AF1oHmFQa9EQ483SXYBe6XRnfZuGftbkRDIdMiZgsVw
docker login -u <USER$> -e test@what.com -p AF1oHmFQa9EQ483SXYBe6XRnfZuGftbkRDIdMiZgsVw https://172.30.6.185:5000/v2/
```

----

### Push the image to the registry

The docker client is now configured to push the image to the OpenShift registry

```
docker push 172.30.6.185:5000/<USER$>/hello-node:v1
```

----

### Create your app on OpenShift

```
oc run hello-node --image=hello-node:v1 --port=8080
deploymentconfig "hello-node" created
```

----

### Check Deployment and Pod

```
oc get deploymentconfig
NAME         REVISION   DESIRED   CURRENT   TRIGGERED BY
hello-node   1          1         1         config

oc get po
NAME                 READY     STATUS    RESTARTS   AGE
hello-node-1-9891e   1/1       Running   0          53s
```

----

### Check metadata about the cluster, events and oc configuration

```
oc get events
oc config view
```

----

### Creating a Pod manifest

Explore the `hello-world` pod configuration file:

```
cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-node
  labels:
    app: hello-node
spec:
  containers:
    - name: hello-node
      image: hello-node:v1
      ports:
        - containerPort: 8080
```
Create the pod using oc:

```
oc delete dc hello-node
oc create -f configs/pod.yaml
```

----

### View Pod details

Use the `oc get` and `kubect describe` commands to view details for the `hello-node` Pod:

```
oc get pods
```

```
oc describe pods <pod-name>
```

----

### Interact with a Pod remotely

Pods are allocated a private IP address by default and cannot be reached outside of the cluster. Use the `oc port-forward`, as allreday done in the previous section, to map a local port to a port inside the `hello-node` pod.

Use two terminals. One to run the `oc port-forward` command, and the other to issue `curl` commands.

----
Terminal 1
```
oc port-forward hello-node 8080 8080
```
Terminal 2
```
curl 0.0.0.0:8080
Hello World!
````

----

### Do it yourself
* Create a `nginx.conf` which returns a 200 "From zero to hero"
* Create a Docker container based on nginx and copy the `nginx.conf` file in that container
* Create a Pod manifest using the new container
* Get output of the application using `curl`or your browser
* Access the pod on port 80 using port-forward
* View the logs of the nginx container

----

### Debugging

### View the logs of a Pod

Use the `oc logs` command to view the logs for the `<PODNAME>` Pod:

```
oc logs <PODNAME>
```

> Use the -f flag and observe what happens.

----

### Run an interactive shell inside a Pod

Like with Docker you can establish an interactive shell to a pod with almost the same sytax. Use the `oc exec` command to run an interactive shell inside the `<PODNAME>` Pod:

```
oc exec -ti <PODNAME> /bin/sh
```

----

