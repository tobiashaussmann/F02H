### Step 1 oc basics

The format of a oc command is: oc [action] [resource]  
This performs the specified action  (like create, describe) on the specified resource (like node, container). You can use --help after the command to get additional info about possible parameters (oc get nodes --help).

Before we start we need to ensure that you're loged-in and OpenShift is running and that `oc` is configured to talk to your cluster:
```
oc version
oc login -u <USER$> -p <PASSWORD>
```

Here we see the available nodes, just one in our case. OpenShift will choose where to deploy our application based on the available Node resources.

----

### Step 2 deploy a simple application 

Let’s run our first app on OpenShift with the oc run command. The run command creates automatically a new deployment for the specified container. This is the simpliest way of deploying a container.

Create a new project

```bash
oc new-project <USER$>
Now using project "<USER$>" on server "https://ip-172-16-254-94.eu-central-1.compute.internal:8443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app centos/ruby-22-centos7~https://github.com/openshift/ruby-ex.git

to build a new example application in Ruby.
```

Deploy a simple application
```
oc run hello-openshift --image=gcr.io/google_containers/echoserver:1.4 --port=8080

deploymentconfig "hello-openshift" created
```

Check that the pods are created correctly via:  
```
oc get pods
```

After executing the command several times you should see an error `CrashLoopBackOff`  
OpenShift makes sure a proviledged container cannot run.  
This is a great feature and it SHOULD NOT be DISABLED for production!  

```
oadm --config=/etc/origin/master/admin.kubeconfig policy add-scc-to-group anyuid system:authenticated
```

For more info:  
https://docs.openshift.com/container-platform/3.4/admin_guide/manage_scc.html#grant-access-to-the-privileged-scc

The changes are applied automatically, but to speed it up, delete the pod.

```
oc get pods
oc delete pod <POD_NAME$>
oc get pods
```

This performed a few things for you:
* searched for a suitable node
* scheduled the application to run on that Node
* configured the cluster to reschedule the instance on a new Node when needed 

----

### list your deploymentconfigs

```bash
oc get deploymentconfig
NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-openshift   1         1         1            1           31s
````

We see that there is 1 deployment running a single instance of your app. 

----

### Step 3 View our app

By default deployed applications are visible only inside the OpenShift cluster. To view that the application output without exposing it externally, we’ll create a route between our terminal and the OpenShift cluster using a proxy:
Find out the pod name
```
oc get pod
```
Create the proxy
```bash
oc port-forward hello-openshift-1-ogizd 8080
```
We now have a connection between our host and the OpenShift cluster.

----

### Inspect your application

With `oc get <obejct>` and `oc describe <object>` you can gather information about the status of your objects like pods, deployments, services, ...

----

### Accessing the application
First you need to connect with a different window via ssh to the server
To see the output of our application, run a curl request in a new terminal window:
```bash
[root@ip-172-16-254-94 ~]# curl http://localhost:8080
CLIENT VALUES:
client_address=127.0.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://localhost:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=localhost:8080
user-agent=curl/7.29.0
BODY:
-no body in request-[root@ip-172-16-254-94 ~]#
```

----

### Expose service while creating the deployment

`oc proxy` is meant for testing services which are not getting exposed. To expose the application we can create a service definition (we come to that) or we let OpenShift do that for us

Stop the proxy with `ctrl+c` and delete the old deployment
```
oc delete deploymentconfig hello-openshift
```
----

Create a new deploymentconfig and a service to expose the application
```
oc run hello-openshift --image=gcr.io/google_containers/echoserver:1.4 --port=8080 --expose --service-overrides='{ "spec": { "type": "NodePort" } }'
service "hello-openshift" created
deploymentconfig "hello-openshift" created
```
This creates a new deployment and a service of type:NodePort. It will get an random high port allocated where we can access the application:

----

View the service:
```
oc get svc
NAME              CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
hello-openshift   172.30.133.74    <nodes>       8080/TCP   30s

oc describe svc hello-openshift
Name:			hello-openshift
Namespace:		training
Labels:			<none>
Selector:		run=hello-openshift
Type:			NodePort
IP:			172.30.133.74
Port:			<unset>	8080/TCP
NodePort:		<unset>	30914/TCP
Endpoints:		10.128.0.19:8080
Session Affinity:	None
No events.
```
Access the application with curl
```
curl <PUBLIC_IP>:30914
```

----

### Cleanup

```
oc delete deploymentconfig,service hello-openshift
deployment "hello-openshift" deleted
service "hello-openshift" deleted
```