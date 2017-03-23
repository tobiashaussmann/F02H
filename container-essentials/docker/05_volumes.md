## Working with Volumes

At the end of this lesson, you will be able to:
* Explain what volumes are and what they are used for
* Learn the different methods of mounting a volume in a container
* Mount volumes during the docker run command and also in a Dockerfile
* Explain how data containers work
* Create some data containers

----

### What is a Volume

* Docker takes the read-only image and adds a read-write layer on top
* If the running container modifies an existing file, the file is copied out to read-write layer where the changes are applied. 
* The version in the read-write layer hides the underlying file, but does not destroy it. 
* When a Docker container is deleted, relaunching the image will start a fresh container without any of the changes made in the previously running container
* In order to be able to save (persist) data and also to share data between containers

----

### Volumes
A Volume is a designated directory in a container, which is designed to persist data, independent of the container’s life cycle

* Volume changes are excluded when updating an image
* Persist when a container is deleted
* Can be mapped to a host folder
* Can be shared between containers

----

### Working with Volumes
Docker volumes can be used:
* De-couple the data that is stored, from the container which created the data
* Bypassing the copy-on-write system to obtain native disk I/O performance.
* Bypassing copy-on-write to leave some files out of docker commit.
* Sharing a directory between multiple containers.
* Sharing a directory between the host and a container.
* Sharing a single file between the host and a container

----

### Docker volume command

The `docker volume` command contains a number of sub commands used to create and manage volumes
Commands are 
```
docker volume create
docker volume ls
docker volume inspect
docker volume rm
```

----

### Creating a volume

There are several ways to initialise volumes, with some subtle differences that are important to understand. The most direct way is declare a volume at run-time with the -v flag:

```
docker run -it --name vol-test -h CONTAINER -v /data bitnami/minideb /bin/bash
root@CONTAINER:/# ls /data
root@CONTAINER:/# 
```

* This will create the directory /data inside the container. 
* Any files that the image held inside the /data directory will be copied into the volume. 

----

We can find out where the volume lives on the host by using the docker inspect command on the host (open a new terminal and leave the previous container running if you’re following along):

```
docker inspect -f "{{json .Mounts}}" vol-test | jq .
[
  {
    "Type": "volume",
    "Name": "b4a206db0715a5024f77a877e4c11a7724f9bf9c5aa6ea6ce50757078e2f5433",
    "Source": "/var/lib/docker/volumes/b4a206db0715a5024f77a877e4c11a7724f9bf9c5aa6ea6ce50757078e2f5433/_data",
    "Destination": "/data",
    "Driver": "local",
    "Mode": "",
    "RW": true,
    "Propagation": ""
  }
]
 
```

----

### Docker network inspect

Now that we know the name of the volume, we can also get similar information from docker volume inspect command:

```
docker volume inspect b4a206db0715a5024f77a877e4c11a7724f9bf9c5aa6ea6ce50757078e2f5433
[
    {
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/b4a206db0715a5024f77a877e4c11a7724f9bf9c5aa6ea6ce50757078e2f5433/_data",
        "Name": "b4a206db0715a5024f77a877e4c11a7724f9bf9c5aa6ea6ce50757078e2f5433",
        "Options": {},
        "Scope": "local"
    }
]
```

In both cases, the output tells us that Docker has mounted /data inside the container as a directory somewhere under /var/lib/docker. 

----

### docker volume create
We can also use the `docker volume create` command and specify the `--name` option
* Specify a name so you can easily find and identify your volume later

```
docker volume create --name my-vol
my-vol
```

----

```
docker volume inspect my-vol
[
    {
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/my-vol/_data",
        "Name": "my-vol",
        "Options": {},
        "Scope": "local"
    }
]
```

----

### Using volumes

```
docker run -d -v my-vol:/data bitnami/minideb
```

This example will mount the my-vol volume at /data inside the container.

----

We can add files under `/var/lib/docker/volumes/<name>/_data/`
```
sudo touch /var/lib/docker/volumes/b4a206db0715a5024f77a877e4c11a7724f9bf9c5aa6ea6ce50757078e2f5433/_data/test-file
sudo touch /var/lib/docker/volumes/my-vol/_data/test-file
```
And the file will be available in the container

```
root@CONTAINER:/# ls /data
test-file
```

----

### Listing volumes

* Use `docker volume ls` command to display a list of all volumes
* This includes volumes that were mounted to containers using the old `docker run -v` method 
* Volumes that were not given a name during creation will have a randomly generated name

```
DRIVER              VOLUME NAME
local               045e85912e993e65cd00ebd4d39df8243c7baa064472d6297701746a41927807
local               06ea6a799cee6f79a09a85d5e65b996ffe594427cc1faf60f8908a2c76632d31
local               files
local               hello.php
local               https
```

----

### Mount a Volume

* Volumes can be mounted when running a container
* Use the `-v` option on `docker run` command and specify the name of the volume and the mount path syntax: `docker run -v <name>:<path> …`
* Path is the container folder where you want to mount the volume
* Can mount multiple volumes by using the `-v` option multiple times

----

### Sharing Data

To give another container access to a container’s volumes, we can provide the `–volumes-from` argument to docker run. For example:

```
docker run -it -h NEWCONTAINER --volumes-from vol-test bitnami/minideb /bin/bash
root@NEWCONTAINER:/# ls /data
test-file
root@NEWCONTAINER:/#
```

This works whether container-test is running or not. A volume will never be deleted as long as a container is linked to it. 

----

We could also have mounted the volume by giving its name to the -v flag i.e:
```


$ docker run -it -h NEWCONTAINER -v b4a206db0715a5024f77a877e4c11a7724f9bf9c5aa6ea6ce50757078e2f5433:/my-data bitnami/minideb /bin/bash
root@NEWCONTAINER:/# ls /my-data
test-file
```

----

### Data containers
Prior to the introduction of the docker volume commands, it was common to use “data containers” for storing persistent and shared data such as databases or configuration data. This approach meant that the container essentially became a “namespace” for the data – a handle for managing it and sharing with other containers. However, in modern versions of Docker, this approach should be never be used – simply create named volumes using docker volume create –name instead.

----

### Permissions and Ownership

Often you will need to set the permissions and ownership on a volume, or initialise the volume with some default data or configuration files. A key point to be aware of here is that anything after the VOLUME instruction in a Dockerfile will not be able to make changes to that volume e.g:
```FROM debian:wheezy
RUN useradd foo
VOLUME /data
RUN touch /data/x
RUN chown -R foo:foo /data
```
Will not work as expected. We want the touch command to run in the image’s filesystem but it is actually running in the volume of a temporary container.

----
The following will work:
```
FROM debian:wheezy
RUN useradd foo
RUN mkdir /data && touch /data/x
RUN chown -R foo:foo /data
VOLUME /data
```
Docker is clever enough to copy any files that exist in the image under the volume mount into the volume and set the ownership correctly.

----

### Deleting Volumes

Chances are, if you’ve been using docker rm to delete your containers, you probably have lots of orphan volumes lying about taking up space.

* Volumes are only automatically deleted if the parent container is removed with the docker rm -v command 
* A volume will only be deleted if no other container links to it. 
* Volumes linked to user specified host directories are never deleted by docker.

----

### Module summary

* Volumes are created with the docker volume create command
* Volumes can be mounted when we run a container during the docker run command or in a Dockerfile
* We can map a host directory to a volume in a container

----