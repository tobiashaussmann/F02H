### Volumes

A Pod is made of one or several containers plus some data volumes that can be mounted inside the containers. In this section you will learn how to: * define volume in Pods
* define a persistent volume
* define a persistent volume claim 

----

### Do it yourselfe

Before going further, you can spend time on this little exercise. It will clarify how volumes are defined in Pods.

* Create a Pod with two containers and one volume shared. 
* You can experiment with `emptyDir` and `hostPath` since those two volume types do not require any additional setup and will work in your Kubernetes cluster. 

----
The volume is of type `emptyDir`. The kubelet will create an empty directory on the node when the Pod is scheduled. Once the Pod is destroyed, the kubelet will delete the directory. This is the simplest type of volumes used in Kubernetes.

```
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: busy
    image: busybox
    volumeMounts:
    - name: test
      mountPath: /busy
    command:
      - sleep
      - "3600"
  - name: box
    image: busybox
    volumeMounts:
    - name: test
      mountPath: /box
    command:
      - sleep
      - "3600"
  volumes:
  - name: test
    emptyDir: {}
```

Then get in each container and check the existence of the directories. Write a file and check that it is available in the other container:

----

```
$ kubectl exec -ti busybox -c box -- touch /box/foobar
$ kubectl exec -ti busybox -c busy -- ls -l /busy
total 0
-rw-r--r--    1 root     root             0 Nov 19 16:26 foobar
```

----

### Persistent Volumes and Claims

We can use HostPath for single node testing (e.g minikube) like in the example below. HostPath volumes survive Pod deletion.

```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv0001
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/somepath/data01"
```

----

Create the PV and check with get and describe the status

```
kubectl create -f pv.yaml
kubectl get pv
kubectl describe pv
```

----

### Defining a Volume Claim

With a persistent volume created in your cluster, you then write a manifest for a claim and use that claim in your Pod definition:

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
```

----

```
kubectl create -f pvc.yaml
kubectl get pvc
kubectl describe pvc
```

----

And in the Pod, the volume type is now persistentVolumeClaim:

```
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: busy
    image: busybox
    volumeMounts:
    - name: test
      mountPath: /busy
    command:
      - sleep
      - "3600"
  - name: box
    image: busybox
    volumeMounts:
    - name: test
      mountPath: /box
    command:
      - sleep
      - "3600"
  volumes:
    - name: test
      persistentVolumeClaim:
        claimName: myclaim
```

----

```
kubectl delete -f pod_volume.yaml
kubectl create -f pod_pvc.yaml
```
Check output of `get`and `describe`on pod, pv and pvc

----

### Dynamic Provisioning

While handling volumes with a persistent volume definition and abstracting the storage provider using a claim is powerful, an administrator of the cluster still needs to create those volumes in the first place.

Since Kubernetes 1.4 it is possible to use dynamic provisioning of persistent volumes (beta)

A new API resource has been introduced in Kubernetes 1.2 called StorageClass. If configured and a user requests a claim, this claim will be created even if an existing pv does not exist. The volume provisioner defined in the StorageClass will dynamically create the volume.

Here is an example of a StorageClass on AWS:

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
```

You might be interested to test this using this [example](https://github.com/kubernetes/kubernetes/tree/master/examples/experimental/persistent-volume-provisioning).

----

### Do it yourselfe

* Create a PV and PVC using HostPath /somepath/log01
* Use the PVC in the nginx POD (Deployment) and map it to /var/log
* Validate the existence

As the host-folder will be empty, there are no logs. Also not in the container.

----

### Cheat

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0002
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/somepath/log01"

---

kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: logclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi

---

apiVersion: v1
kind: Pod
metadata:
  name: nginx-logs
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: logs
      mountPath: /var/log
    command:
      - sleep
      - "3600"
  volumes:
    - name: logs
      persistentVolumeClaim:
        claimName: logclaim