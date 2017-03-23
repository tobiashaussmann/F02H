### What is ingress?

Typically, services and pods have IPs only routable by the cluster network. All traffic that ends up at an edge router is either dropped or forwarded elsewhere. Conceptually, this might look like:
```
    internet
        |
  ------------
  [ Services ]
```
An Ingress is a collection of rules that allow inbound connections to reach the cluster services.
```
    internet
        |
   [ Ingress ]
   --|-----|--
   [ Services ]
```

----

It can be configured:
* to give services externally-reachable urls
* load balance traffic
* terminate SSL
* offer name based virtual hosting 

An Ingress controller is responsible for fulfilling the Ingress, usually with a loadbalancer, though it may also configure your edge router or additional frontends to help handle the traffic in an HA manner.

----

### Ingress controller

In order for the Ingress resource to work, the cluster must have an Ingress controller running

An Ingress Controller is a daemon, deployed as a Kubernetes Pod, that watches the ApiServer's /ingresses endpoint for updates to the Ingress resource. Its job is to satisfy requests for ingress.

Workflow:
* Poll until apiserver reports a new Ingress
* Write the LB config file based on a go text/template
* Reload LB config

----

### Example
Ingress resource
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata: 
  name: frontend-ingress
spec: 
  rules: 
    - 
      host: frontend.example.com
      http: 
        paths: 
          - 
            backend: 
              serviceName: front-end
              servicePort: 80
            path: /
```
*POSTing this to the API server will have no effect if you have not configured an Ingress controller.*

----

This is a ingress controller based on nginx. There are others like HAProxy or Traefik available. They can easily be exchanged. To check which one is best suited for you, please check the documentation of the loadbalancers if they meet your requirements.
There are also implementations for hardware loadbalancers like F5 available, but I haven't seen them used out in the wild.

```
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: ingress-controller
  labels:
    k8s-app: ingress-controller
    component: core
spec:
  template:
    metadata:
      labels:
        k8s-app: ingress-controller
        component: core
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - image: gcr.io/google_containers/nginx-ingress-controller:0.8.3
        name: ingress-controller-core
        imagePullPolicy: Always
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        # use downward API
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        ports:
        - containerPort: 80
          hostPort: 80
        - containerPort: 443
          hostPort: 443
        args:
        - /nginx-ingress-controller
        - --default-backend-service=$(POD_NAMESPACE)/ingress-controller-defb
        - --nginx-configmap=$(POD_NAMESPACE)/ingress-controller-config
        - --v=3
        volumeMounts:
          - mountPath: /etc/nginx/template
            name: config-template
            readOnly: true
      volumes:
        - name: config-template
          configMap:
            name: ingress-controller-config-template
            items:
            - key: nginx.tmpl
              path: nginx.tmpl
```

Here you see a DaemonSet. DaemonSets are currently in beta, that's why we don't go any deeper here. DaemonSets ensure that on each node one instance is of the specified pod is running. You can do the same with NodeSelectors and RC/RS/Deployments, but for portability DaemonSets are a better fit. For the ingress controller ifself it makes no difference.

----

### Try it!

* Deploy the content of the ingress folder ```kubectl create -f ingress```

Hint: with the above command you specify a folder and k8s will deploy everything in this folder.

Test it
```bash
curl -I -H 'Host: frontend.example.com' localhost
```

----

### Do it yourself

* Write a ingress manifest to expose the nginx service on port 80
* Access the nginx via `curl` or a browser on port 80
 
 You don't need to change the controller
