## Creating and Managing Builds

OpenShift allows to build Docker images from different sources.

In this section we will create a simple `BuildConfig` manifest which
* Has as source a public GIT repository.
* Uses a specific branch.
* Triggers the build automatically, as soon as the manifest is deployed.
* Outputs the image to OpenShift registry.
* Deploy via the UI.

----

An example of a BuildConfig is the following Prometheus.  
```
---
apiVersion: v1
kind: Template
labels: {}
metadata:
  description: Prometheus
  labels: {}
  name: prometheus
objects:
- kind: ImageStream
  apiVersion: v1
  metadata:
    name: prometheus
    creationTimestamp: 
  spec:
    tags:
    - name: 0.0.1
      annotations:
        description: prometheus
        iconClass: icon-database
        tags: service,prometheus
        version: 0.0.1
- kind: BuildConfig
  apiVersion: v1
  metadata:
    name: prometheus
  spec:
    triggers:
    - type: ImageChange
    - type: ConfigChange
    source:
      type: Git
      git:
        uri: https://github.com/silenteh/prometheus-kafka.git
        ref: simple
    strategy:
      type: Docker
      dockerStrategy:
        noCache: true
    output:
      to:
        kind: ImageStreamTag
        name: prometheus:0.0.1
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      prometheus.io/port: '9090'
      prometheus.io/scrape: 'true'
    labels:
      project: prometheus
      name: prometheus
    name: prometheus
  spec:
    deprecatedPublicIPs: []
    externalIPs: []
    ports:
    - port: 9090
      protocol: TCP
      targetPort: 9090
    selector:
      project: prometheus
      name: prometheus
    type: NodePort
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    labels:
      project: prometheus
      name: prometheus
    name: prometheus
  spec:
    replicas: 1
    selector:
      project: prometheus
      name: prometheus
    triggers:
    - type: "ImageChange"
      imageChangeParams:
        automatic: true
        from:
            kind: "ImageStreamTag"
            name: "prometheus:0.0.1"
            namespace: "admin"
        containerNames:
            - "prometheus"
    template:
      metadata:
        annotations: {}
        labels:
          project: prometheus
          name: prometheus
      spec:
        containers:
        - args:
          - "-storage.local.retention=6h"
          - "-storage.local.memory-chunks=500000"
          - "-config.file=/etc/prometheus/prometheus.yml"
          command: []
          env:
          - name: prometheus
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          image: "${PROMETHEUS_IMAGE}:0.0.1"
          livenessProbe:
            tcpSocket:
              port: 9090
          name: prometheus
          ports:
          - containerPort: 9090
            name: http
          imagePullPolicy: Always
          securityContext: {}
          volumeMounts:
          - mountPath: "/prometheus"
            name: prometheus-data
            readOnly: false
        imagePullSecrets: []
        nodeSelector: {}
        volumes:
        - emptyDir:
            medium: ''
          name: prometheus-data
parameters:
- name: PROMETHEUS_IMAGE
  displayName: Prometheus exporter Docker Image
  description: The name of Prometheus exporter Docker image to use
  value: REGISTRY_IP:5000/NAMESPACE/prometheus
```

Now try to Start a new build and see what happens....  
When combined with hooks, this becomes a powerful CI/CD mechanism for deploying software.

---

## Deploy Grafana

```
---
kind: Template
apiVersion: v1
metadata:
  name: grafana
  creationTimestamp: 
  annotations:
    openshift.io/display-name: grafana
    description: Install Grafana in OpenShift
    iconClass: icon-metrics
    tags: database,grafana,queue
message: 'The following service(s) have been created in your project: Grafana.'
labels:
  template: grafana
objects:
- kind: ImageStream
  apiVersion: v1
  metadata:
    name: grafana
    creationTimestamp: 
  spec:
    tags:
    - name: 3.1.1
      annotations:
        description: Provides Grafana 3.1.1
        iconClass: icon-database
        tags: service,grafana
        version: 3.1.1
- kind: BuildConfig
  apiVersion: v1
  metadata:
    name: grafana
  spec:
    triggers:
    - type: ImageChange
    - type: ConfigChange
    source:
      type: Git
      git:
        uri: https://github.com/silenteh/grafana-docker.git
        ref: master
    strategy:
      type: Docker
      dockerStrategy:
        noCache: true
    output:
      to:
        kind: ImageStreamTag
        name: grafana:3.1.1
- kind: Service
  apiVersion: v1
  metadata:
    name: grafana-loadbalancer
    creationTimestamp: 
    labels:
      name: grafana-egress
  spec:
    ports:
    - name: client
      protocol: TCP
      port: 3000
      targetPort: 3000
    selector:
      name: grafana
    type: NodePort
- kind: Service
  apiVersion: v1
  metadata:
    name: grafana-cluster
    creationTimestamp: 
    labels:
      name: grafana-cluster
  spec:
    ports:
    - name: client
      protocol: TCP
      port: 3000
      targetPort: 3000
      nodePort: 0
    selector:
      name: grafana
    type: ClusterIP
    sessionAffinity: None
  status:
    loadBalancer: {}
- kind: DeploymentConfig
  apiVersion: v1
  metadata:
    name: grafana-deployment
    creationTimestamp: 
    labels:
      name: grafana
      app: grafana
  spec:
    template:
      metadata:
        labels:
          name: grafana
      spec:
        volumes:
        - name: grafana-persistent-storage
          emptyDir: {}
        containers:
        - name: grafana-core
          image: "${GRAFANA_IMAGE}:3.1.1"
          ports:
          - containerPort: 3000
            protocol: TCP
          env:
          - name: GF_AUTH_BASIC_ENABLED
            value: 'true'
          - name: GF_AUTH_ANONYMOUS_ENABLED
            value: 'false'
          volumeMounts:
          - name: grafana-persistent-storage
            mountPath: "/var"
          resources: {}
          terminationMessagePath: "/dev/termination-log"
          imagePullPolicy: Always
          securityContext:
            capabilities: {}
            privileged: false
          livenessProbe:
            tcpSocket:
              port: 3000
            initialDelaySeconds: 15
            timeoutSeconds: 15
          readinessProbe:
            tcpSocket:
              port: 3000
            initialDelaySeconds: 15
            timeoutSeconds: 15
    replicas: 1
    triggers:
    - type: ImageChange
      imageChangeParams:
        automatic: true
        from:
          kind: ImageStreamTag
          name: grafana:3.1.1
        containerNames:
        - grafana-core
    strategy:
      type: Recreate
    paused: false
    revisionHistoryLimit: 2
    minReadySeconds: 0
parameters:
- name: GRAFANA_IMAGE
  displayName: Kafka Docker Image
  description: The name of Kafka Docker image to use
  value: REGISTRY_IP:5000/namespace/grafana

```

Locate now the NodePort and try to open it, in the browser.  
You can follow the next steps and configure Prometheus as data source with the following settings:

- Host: `http://prometheus:9090/`
- Connection type: `proxy`

Now click on the tab `Dashboards` and import `Prometheus DashBoard`

Profit !
