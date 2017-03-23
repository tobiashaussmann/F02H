ConfigMaps are similar to Secrets, only that they are designed to more conveniently support working with strings that do not contain sensitive information. They can be used to store individual properties in form of key-value pairs. However, the values can also be entire config files or JSON blobs to store more information.
In this section you will learn how to: 
* use ConfigMaps

----

### ConfigMaps

ConfigMap hold both fine- and/or coarse-grained data. Applications read configuration settings from both environment variables and files containing configuration data, ConfigMap support both methods. 

Example ConfigMap that contains both types of configuration:

```
apiVersion: v1
 kind: ConfigMap
 metadata:
   Name: example-configmap
 data:
   # property-like keys
   game-properties-file-name: game.properties
   ui-properties-file-name: ui.properties
   # file-like keys
   game.properties: |
     enemies=aliens
     lives=3
     enemies.cheat=true
     enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30
  ui.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice
```
To create this config map you can issue ```kubectl create -f <filename>```

The property-like keys of the ConfigMap are used as environment variables to the single container in the Deployment template, and the file-like keys populate a volume.

### Consuming in Environment Variables

A ConfigMap can be used to populate the value of command line arguments. For example, consider the following ConfigMap:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  special.how: very
  special.type: charm
```

----

You can consume the keys of this ConfigMap in a pod using configMapKeyRef sections:
```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.type
  restartPolicy: Never
```
When this pod is run, its output will include the following lines:
```
SPECIAL_LEVEL_KEY=very
SPECIAL_TYPE_KEY=charm
```

----

### Setting Command-line Arguments
A ConfigMap can also be used to set the value of the command or arguments in a container. This is accomplished using the Kubernetes substitution syntax $(VAR_NAME). Consider the same ConfigMap as above.

----

### Consuming in Volumes

A ConfigMap can also be consumed in volumes. Returning again to the above ConfigMap

You have a couple different options for consuming this ConfigMap in a volume. The most basic way is to populate the volume with files where the key is the file name and the content of the file is the value of the key.

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "cat", "/etc/config/special.how" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
  restartPolicy: Never
```
When the pod is running, the output will be:
```
very charm
```

----

You can also define the paths within the volume where ConfigMap keys are stored:

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "cat", "/etc/config/path/to/special-key" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
        items:
        - key: special.how
          path: path/to/special-key
  restartPolicy: Never
```
When the pod is running, the output will be:
```
very
```

----

### Do it yourselfe

For a real-world example, you can configure Redis using a ConfigMap. To inject Redis with the recommended configuration for using Redis as a cache, the Redis configuration file(called redis-config) should contain the following:
```
maxmemory 2mb
maxmemory-policy allkeys-lru
```
* Create a configfile containing the values
* Create a ConfigMap called `example-redis-config` from that file
* Validate the results
* Create a Pod whith
```
      configMap:
        name: example-redis-config
        items:
        - key: redis-config
          path: redis.config
```

----

### Validate

```
kubectl exec -it redis redis-cli
127.0.0.1:6379> CONFIG GET maxmemory
1) "maxmemory"
2) "2097152"
127.0.0.1:6379> CONFIG GET maxmemory-policy
1) "maxmemory-policy"
2) "allkeys-lru"
```

----

### cheat

```
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: kubernetes/redis:v1
    env:
    - name: MASTER
      value: "true"
    ports:
    - containerPort: 6379
    volumeMounts:
    - mountPath: /redis-master
      name: config
  volumes:
    - name: config
      configMap:
        name: example-redis-config
        items:
        - key: redis-config
          path: redis.conf
```