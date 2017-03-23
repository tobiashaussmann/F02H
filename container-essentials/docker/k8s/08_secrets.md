In this section you will learn:
* How to create secrets
* use secrets

----

### Secrets in action

We want to share the value some-base64-encoded-payload under the key my-super-secret-key as a Kubernetes Secret for a pod. 
First you need to base64-encode it like so:
```
echo -n some-base64-encoded-payload | base64
c29tZS1iYXNlNjQtZW5jb2RlZC1wYXlsb2Fk
```

Note the -n parameter with echo; this is necessary to suppress the trailing newline character. 

----

### Creating the secret

We put the result of the base64 encoding into the secret manifest
```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  my-super-secret-key: c29tZS1iYXNlNjQtZW5jb2RlZC1wYXlsb2Fk
```
Currently there is no other type available, also no other "encryption" method despite base64 encoding
----

### Using Secret

Create a pod with that secret
```
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: secret
  name: secret
spec:
  volumes:
    - name: "secret"
      secret:
        secretName: mysecret
  containers:
    - image: nginx
      name: webserver
      volumeMounts:
        - mountPath: "/tmp/mysec"
          name: "secret"
```
```
kubectl create -f secret.yaml -f pod_secret.yaml
```

----

### Validate Secret

```
kubectl exec -ti secret /bin/bash
cat /tmp/mysec/my-super-secret-key
```

----

One word of warning here, in case it’s not obvious: secret.yaml should never ever be committed to a source control system such as Git. If you do that, you’re exposing the secret and the whole exercise would have been for nothing.

