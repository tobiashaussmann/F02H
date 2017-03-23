## Understanding Docker images
In this lesson, I’ll explain:
* What is an image.
* What is a layer.
* The various image namespaces.
* How to search and download images
* Writing a basic Dockerfile

----

### What is an image?

* An image is a collection of files + some meta data.  
(Technically: those files form the root filesystem of a container.)
* Images are made of layers, conceptually stacked on top of each other.
* Each layer can add, change, and remove files.
* Images can share layers to optimize disk usage, transfer times, and memory use.
* When we start a container, Docker takes the read-only image and adds a read-write layer on top.

----

### Difference between container and image

* An image is a read-only filesystem.
* A container is an encapsulated set of processes running in a read-write copy of that filesystem.
* To optimize container boot time, copy-on-write is used instead of regular copy.
* docker run starts a container from a given image.

Images are like templates or stencils that you can create containers from.

----

### Union File System
* If the running container modifies an existing file, the file is copied out into the top-most read-write layer 
* The version in the read-write layer hides the underlying file, but does not destroy it.

----

### But…

If an image is read-only, how do we change it?
* We don't.
* We create a new container from that image.
* Then we make changes to that container.
* When we are satisfied with those changes, we transform them into a new layer.
* A new image is created by stacking the new layer on top of the old image.

----

Confusion (chicken-and-egg):
* The only way to create an image is by "freezing" a container.
* The only way to create a container is by instanciating an image.

----

### Creating the 1st images

There is a special empty image called `scratch`.
* It allows to build from scratch.
The `docker import` command loads a tarball into Docker.
* The imported tarball becomes a standalone image.
* That new image has a single layer.

Note: you will probably never have to do this yourself.

----

### Creating other images

`docker commit`
* Saves all the changes made to a container into a new layer.
* Creates a new image (effectively a copy of the container).
`docker build`
* Performs a repeatable build sequence.
* This is the **preferred** method!

----

### Image namespaces
There are three namespaces:
* Root-like
    * ubuntu
* User (and organizations)
    * bitnami/minideb
* Self-Hosted
    * registry.example.com:5000/my-private-image

----

### Root namespaces
The root namespace is for official images. They aren't put there by Docker Inc., but they are generally authored and maintained by third parties.

Those images include:
* Small, "swiss-army-knife" images like busybox.
* Distro images to be used as bases for your builds, like ubuntu, fedora...
* Ready-to-use components and services, like redis, postgresql...

----

### User namespaces
The user namespace holds images for Docker Hub users and organizations.
For example:
* muellermich/nodejs-hello
The Docker Hub user is:
* muellermich
The image name is:
* nodejs-hello

----

### Self-hosted namespace

This namespace holds images which are not hosted on Docker Hub, but on third party registries.

They contain the hostname (or IP address), and optionally the port, of the registry server.
For example:
* localhost:5000/wordpress
The remote host and port is:
* localhost:5000
The image name is:
* wordpress

----

### List images on your host

```bash
docker images
REPOSITORY                                  TAG                                 IMAGE ID            CREATED             SIZE
muellermich/reveal-md                       latest                              92670cf55bca        3 days ago          689.3 MB
reveal-md                                   latest                              92670cf55bca        3 days ago          689.3 MB
muellermich/reveal-md                       <none>                              bffc6af76db3        3 days ago          711.8 MB
muellermich/reveal-md                       <none>                              f4767cdedb2b        3 days ago          689.5 MB
muellermich/reveal-md                       <none>                              9a4005187039        3 days ago          689.6 MB
muellermich/reveal-md                       <none>                              0f63ac533bf2        3 days ago          689.5 MB
muellermich/reveal-md                       <none>                              e6a7dfbfd82a        3 days ago          689.4 MB
<none>                                      <none>                              04ead644d638        3 days ago          689.5 MB
<none>                                      <none>                              50af7f43d702        3 days ago          689.5 MB
<none>                                      <none>                              622748c50d8f        3 days ago          673.8 MB
muellermich/reveal-md                       <none>                              57bec2477c00        3 days ago          689.5 MB
<none>                                      <none>                              303087ff0bab        3 days ago          689.5 MB
<none>                                      <none>                              10cecf3ef742        3 days ago          689.4 MB
```

----

### Searching for images
    
```bash
docker search nginx
NAME                                     DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
nginx                                    Official build of Nginx.                        3784      [OK]       
jwilder/nginx-proxy                      Automated Nginx reverse proxy for docker c...   757                  [OK]
richarvey/nginx-php-fpm                  Container running Nginx + PHP-FPM capable ...   245                  [OK]
jrcs/letsencrypt-nginx-proxy-companion   LetsEncrypt container to use with nginx as...   92                   [OK]
million12/nginx-php                      Nginx + PHP-FPM 5.5, 5.6, 7.0 (NG), CentOS...   76                   [OK]
maxexcloo/nginx-php                      Docker framework container with Nginx and ...   57                   [OK]
webdevops/php-nginx                      Nginx with PHP-FPM                              47                   [OK]
h3nrik/nginx-ldap                        NGINX web server with LDAP/AD, SSL and pro...   28                   [OK]
bitnami/nginx                            Bitnami nginx Docker Image                      18                   [OK]
maxexcloo/nginx                          Docker framework container with Nginx inst...   7                    [OK]
evild/alpine-nginx                       Minimalistic Docker image with Nginx            6                    [OK]
million12/nginx                          Nginx: extensible, nicely tuned for better...   6                    [OK]
webdevops/nginx                          Nginx container                                 5                    [OK]
ixbox/nginx                              Nginx on Alpine Linux.                          3                    [OK]
webdevops/hhvm-nginx                     Nginx with HHVM                                 3                    [OK]
dock0/nginx                              Arch container running nginx                    2                    [OK]
1science/nginx                           Nginx Docker images based on Alpine Linux       2                    [OK]
yfix/nginx                               Yfix own build of the nginx-extras package      2                    [OK]
xataz/nginx                              Light nginx image                               2                    [OK]
blacklabelops/nginx                      Dockerized Nginx Reverse Proxy Server.          1                    [OK]
servivum/nginx                           Nginx Docker Image with Useful Tools            1                    [OK]
radial/nginx                             Spoke container for Nginx, a high performa...   1                    [OK]
tozd/nginx                               Dockerized nginx.                               0                    [OK]
c4tech/nginx                             Several nginx images for web applications.      0                    [OK]
unblibraries/nginx                       Baseline non-PHP nginx container                0                    [OK]
```

----

### Downloading images

There are two ways to download images.
* Explicitly, with `docker pull`.
* Implicitly, when executing `docker run` and the image is not found locally.

----

### Pulling an image
```bash
docker pull alpine:latest
```
As seen previously, images are made up of layers.
* Docker has downloaded all the necessary layers.
* In this example, :latest indicates that we pulled the lastest Version of Alpine Linux.

----

### Image and Tags
Images can have tags.
* Tags define image versions or variants.
* `docker pull alpine` will refer to `alpine:latest`.
The `:latest` tag is generally updated often.

----

### When to use or not to use tags
Don't specify tags:
* When doing rapid testing and prototyping.
* When experimenting.
* When you want the latest version.
Do specify tags:
* When recording a procedure into a script.
* When going to production.
* To ensure that the same version will be used everywhere.
* To ensure repeatability later

----

### Docker tracks filesystem changes

* An image is read-only.
* When we make changes, they happen in a copy of the image.
* Docker can show the difference between the image, and its copy.
* For performance, Docker uses copy-on-write systems.  
(i.e. starting a container based on a big image doesn't incur a huge copy.)

----

### Inspect the changes
Now let's run `docker diff` on the figlet container to see the difference between the base image and our container.

```bash
docker diff $(docker ps -alq)
C /.wh..wh.plnk
A /.wh..wh.plnk/98.3683338
C /etc
C /etc/alternatives
A /etc/alternatives/figlet
A /etc/alternatives/figlet.6.gz
C /tmp
C /usr
C /usr/bin
A /usr/bin/chkfont
A /usr/bin/figlet
A /usr/bin/figlet-figlet
A /usr/bin/figlist
A /usr/bin/showfigfonts
C /usr/share
```

----

### Small security excursus

* With `diff` it's poosible to see what files an attacker changed, if you got hacked
* With `commit` you can save the state for later analysis
* If a hacker changed a file, you can revert this change by a restart of a container

----

## Building images with a Dockerfile

We will build a container image automatically, with a Dockerfile.
At the end of this lesson, you will be able to:
* Write a Dockerfile.
* Build an image from a Dockerfile.

----

### Dockerfile overview

A Dockerfile is a build recipe for a Docker image.
* It contains a series of instructions telling Docker how an image is constructed.
* The docker build command builds an image from a Dockerfile.

----

### Why do we need to use Dockerfile?

* Dockerfile is not yet-another shell. Dockerfile has its special mission: automation of Docker image creation.
* Once, you write build instructions into Dockerfile, you can build the same image just with docker build command.
* Dockerfile is also useful and acts as a kind of documentation what a container does.

----

### Adding files from Host to Images

Sometimes there is the need to add files to images, e.g.: binaries, files, ...

For this you can use ADD and/or COPY

----

### Difference of ADD and COPY

The ADD instruction copies new files, directories or remote file URLs from <src> and adds them to the filesystem of the image at the path <dest>:
* `ADD` allows <src> to be an URL
* If the <src> parameter of ADD is an archive in a recognised compression format, it will be unpacked
The `COPY` instruction copies new files or directories from <src> and adds them to the filesystem of the container at the path <dest>:

----

### Writing our first Dockerfile

Our Dockerfile should be in a new, empty directory.
* Create a directory to hold our Dockerfile.
```bash
mkdir myimage
```
* Create a Dockerfile inside this directory.
```bash
cd myimage
vim Dockerfile
```
Of course, you can use any other editor of your choice. Or using a container with the editor of your choice :-)

----

### Type this in your Dockerfile…

```bash
FROM bitnami/minideb
RUN apt-get update
RUN apt-get install -y figlet
```
* `FROM` indicates the base image for our build.
* Each `RUN` line will be executed by Docker during the build.
* Our RUN commands must be non-interactive.  
(No input can be provided to Docker during the build that’s why we will add the -y flag to apt-get.)

----

### Build that… image
Save our file, then execute:
```
docker build -t figlet .
```
* `-t` indicates the tag to apply to the image.
* `.` indicates the location of the build context.  
(We will talk more about the build context later; but to keep things simple: this is the directory where our Dockerfile is located.)

----

### What happens when we build the image?

The output of docker build looks like this:
```
docker build -t filget .
Sending build context to Docker daemon 84.48 kB
Step 1 : FROM bitnami/minideb
 ---> 42118e3df429
Step 2 : RUN apt-get update
 ---> Using cache
 ---> 48fb734e0326
Step 3 : RUN apt-get install -y figlet
 ---> Using cache
 ---> ccd7cf351f38
Successfully built ccd7cf351f38
```
The output of the run commands has been omitted
* A container (42118e3df429) is created from the base image.
* The RUN command is executed in this container.
* The container is committed into an image (48fb734e0326).
* The build container (42118e3df429) is removed.
* The output of this step will be the base image for the next one.
* …

----

### Sending the build context to Docker

```
Sending build context to Docker daemon 84.48 kB
```
* The build context is the . directory given to docker build.
* It is sent (as an archive) by the Docker client to the Docker daemon.
* This allows to use a remote machine to build using local files.
* Be careful (or patient) if that directory is big and your link is slow

----

### Behind the scenes

* The Docker client creates a tarball of the current directory and sends it to the Docker daemon. 
* The Docker daemon can also be running on remote machines.
* Prevent to have huge files in the folder if you don't need them. It will accellerate the process.

----

### The caching system

If you run the same build again, it will be instantaneous.  
Why?
* After each build step, Docker takes a snapshot.
* Before executing a step, Docker checks if it has already built the same sequence.
* Docker uses the exact strings defined in your Dockerfile:
    * `RUN apt-get install figlet cowsay` is different from
    * `RUN apt-get install cowsay figlet`
    * `RUN apt-get update` is not re-executed when the mirrors are updated

You can force a rebuild with docker build --no-cache ....

----

### Cache invalidation

* If you cause cache invalidation at one instruction, subsequent instructions doesn’t use cache.
* Cache is invalid even when adding commands that don’t do anything like adding `&& true``
* Cache is invalid when you add spaces between command and arguments inside instruction

----

### Cache used

* Cache is used when you add spaces around commands inside instruction
* Cache is used for non-idempotent instructions e.g.: apt-get update
* For the ADD and COPY instructions, the contents of the file(s) in the image are examined and a checksum is calculated

----

### Run it

```bash
docker run -ti figlet
```
```
root@00f0766080ed:/# figlet hello
 _          _ _       
| |__   ___| | | ___  
| '_ \ / _ \ | |/ _ \ 
| | | |  __/ | | (_) |
|_| |_|\___|_|_|\___/ 
                      
root@00f0766080ed:/# 
```

----

### Using image and showing history

The history command lists all the layers composing an image. 
For each layer, it shows its creation time, size, and creation command. 
When an image was built with a Dockerfile, each layer corresponds to a line of the Dockerfile.

```
docker history figlet
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
889cce7caa31        2 weeks ago         /bin/bash                                       39.65 MB            
42118e3df429        3 weeks ago         /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B                 
<missing>           3 weeks ago         /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$/   1.895 kB            
<missing>           3 weeks ago         /bin/sh -c rm -rf /var/lib/apt/lists/*          0 B                 
<missing>           3 weeks ago         /bin/sh -c set -xe   && echo '#!/bin/sh' > /u   745 B               
<missing>           3 weeks ago         /bin/sh -c #(nop) ADD file:fdbd881d78f9d7d924   124.8 MB        
```

----

### Do it youself

* Create a Dockerfile
    * Install cowsay
    * make the symbolic link `ln -s /usr/games/cowsay /usr/bin/cowsay` static in the Dockerfile
* Build the image
* Run the container from that image
* Run cowsay

----

### Do it yourself

* Create a Dockerfile
    * Install fotunr
* Build the image
* Commit you change
Hint:
```
ln -s /usr/games/fortune /usr/bin/fortune
```

----

### Possible Solution

```
FROM bitnami/minideb:latest
RUN apt-get update
RUN apt-get install -y fortune
RUN ln -s /usr/games/fortune /usr/bin/fortune
```
```
docker run -ti <imagename>
fortune
```

----

### CMD and Entrypoint
In this lesson, we will learn about two important Dockerfile commands: 
* CMD and ENTRYPOINT.

Those commands allow us to set the default command to run in a container so the container acts as a single executable binary.

----

### Defining a default command
When people run our container, we want to welcome them with a nice hello message, and using a custom font.
For that, we will execute:
```bash
figlet -f script hello
```

* `-f script` tells figlet to use a fancy font.
* hello is the message that we want it to display.

----

### Adding CMD to our Dockerfile
To run a commanf `CMD`is used
Our new Dockerfile will look like this:
```bash
FROM bitnami/minideb:latest
RUN apt-get update
RUN apt-get install -y figlet
CMD figlet -f script hello
```
* `CMD` defines a default command to run when none is given.
* It can appear at any point in the file.
* Each CMD will replace and override the previous one.
* As a result, while you can have multiple CMD lines, it is useless.

----

### Build and test…

Build the image
```bash
Sending build context to Docker daemon 2.048 kB
Step 1/4 : FROM bitnami/minideb:latest
 ---> e4bbde5042ed
Step 2/4 : RUN apt-get update
 ---> Running in 57363c98bbd7
Get:1 http://security.debian.org jessie/updates InRelease [63.1 kB]
Get:2 http://security.debian.org jessie/updates/main amd64 Packages [431 kB]
Ign http://httpredir.debian.org jessie InRelease
Get:3 http://httpredir.debian.org jessie Release.gpg [2373 B]
Get:4 http://httpredir.debian.org jessie Release [148 kB]
Get:5 http://httpredir.debian.org jessie/main amd64 Packages [9064 kB]
Fetched 9709 kB in 4s (2166 kB/s)
Reading package lists...
 ---> dcac7c8b445e
Removing intermediate container 57363c98bbd7
Step 3/4 : RUN apt-get install -y figlet
 ---> Running in 44a4d06bbaf9
Reading package lists...
Building dependency tree...
Reading state information...
The following NEW packages will be installed:
  figlet
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 189 kB of archives.
After this operation, 748 kB of additional disk space will be used.
Get:1 http://httpredir.debian.org/debian/ jessie/main figlet amd64 2.2.5-2 [189 kB]
debconf: delaying package configuration, since apt-utils is not installed
Fetched 189 kB in 0s (228 kB/s)
Selecting previously unselected package figlet.
(Reading database ... 6137 files and directories currently installed.)
Preparing to unpack .../figlet_2.2.5-2_amd64.deb ...
Unpacking figlet (2.2.5-2) ...
Setting up figlet (2.2.5-2) ...
update-alternatives: using /usr/bin/figlet-figlet to provide /usr/bin/figlet (figlet) in auto mode
 ---> e1ebfc119d49
Removing intermediate container 44a4d06bbaf9
Step 4/4 : CMD figlet -f script hello
 ---> Running in 4af1809a9c3c
 ---> 45773b5812fa
Removing intermediate container 4af1809a9c3c
Successfully built 45773b5812fa
```

----

Run it
```bash
docker run -ti figlet
 _          _   _       
| |        | | | |      
| |     _  | | | |  __  
|/ \   |/  |/  |/  /  \_
|   |_/|__/|__/|__/\__/ 
```

----

### Overriding CMD

If we want to get a shell into our container (instead of running figlet), we just have to specify a different program to run:
```bash
docker run -ti figlet /bin/bash
root@ca2a5d0b77c5:/# 
```

* We specified `bash`.
* It replaced the value of `CMD`.

----

### Using ENTRYPOINT
We want to be able to specify a different message on the command line, while retaining figlet and some default parameters.
In other words, we would like to be able to do this:
```bash
docker run -ti figlet salut
           _            
          | |           
 ,   __,  | |       _|_ 
/ \_/  |  |/  |   |  |  
 \/ \_/|_/|__/ \_/|_/|_/
```

----

Our new Dockerfile will look like this:
```bash
FROM ubuntu
RUN apt-get update
RUN apt-get install figlet
ENTRYPOINT ["figlet", "-f", "script"]
```

### Using ENTRYPOINT
* `ENTRYPOINT` defines a base command (and its parameters) for the container.
* The command line arguments are appended to those parameters.
* Like `CMD`, `ENTRYPOINT` can appear anywhere, and replaces the previous value.

----

### Build and testing

Build it
```bash
docker build -t figlet .
Sending build context to Docker daemon 92.67 kB
Step 1 : FROM ubuntu
 ---> 42118e3df429
Step 2 : RUN apt-get update
 ---> Using cache
 ---> 48fb734e0326
Step 3 : RUN apt-get install -y figlet
 ---> Using cache
 ---> ccd7cf351f38
Step 4 : CMD figlet -f script hello
 ---> Using cache
 ---> acd649aa600f
Step 5 : ENTRYPOINT figlet -f script
 ---> Running in e82df54f8b7e
 ---> e1003780fba8
Removing intermediate container e82df54f8b7e
Successfully built e1003780fba8
```

----

Run it
```bash
docker run -ti figlet salut
           _            
          | |           
 ,   __,  | |       _|_ 
/ \_/  |  |/  |   |  |  
 \/ \_/|_/|__/ \_/|_/|_/
```

----

### What if we want to use CMD and Entrypoint together?
Then we will use `ENTRYPOINT` and `CMD` together.
* `ENTRYPOINT` will define the base command for our container.
* `CMD` will define the default parameter(s) for this command.

----

### The DOCKERFILE
Our new `DOCKERFILE` will look like this:
```bash
FROM ubuntu
RUN apt-get update
RUN apt-get install -y figlet
ENTRYPOINT ["figlet", "-f", "script"]
CMD ["hello"]
```
* `ENTRYPOINT` defines a base command (and its parameters) for the container.
* If we don't specify extra command-line arguments when starting the container, the value of CMD is appended.
* Otherwise, our extra command-line arguments are used instead of CMD.

----

### Build and test
Build it
```bash
docker build -t figlet .
```
Run it
```
docker run -ti figlet
 _          _   _       
| |        | | | |      
| |     _  | | | |  __  
|/ \   |/  |/  |/  /  \_
|   |_/|__/|__/|__/\__/ 
```
```bash
docker run -ti figlet salut
           _            
          | |           
 ,   __,  | |       _|_ 
/ \_/  |  |/  |   |  |  
 \/ \_/|_/|__/ \_/|_/|_/
```

----

### Overriding ENTRYPOINT
What if we want to run a shell in our container? 
We cannot just do `docker run -ti figlet /bin/bash` because that would just tell figlet to display the word "/bin/bash." 

We use the `--entrypoint` parameter:

```bash
docker run -ti --entrypoint /bin/bash figlet
root@c138bf9ec9ad:/# 
```

----

### Do it yourself
* Create a Dockerfile which pings a given address and a default address 8.8.8.8
    * Base image is minideb
    * Create an ENTRYPOINT to define the base command
    * And with CMD define the default parameter for this command.
* Build the image
* run the image

----

### Possible Solution
```bash
FROM bitnami/minideb
RUN apt-get update && apt-get install -y iputils-ping
ENTRYPOINT ["ping"]
CMD ["8.8.8.8"]
```

----

### Copying files during the build
So far, we have installed things in our container images by downloading packages. 
We can also copy files from the build context to the container that we are building (described allready). 

Remember: the build context is the directory containing the Dockerfile. 

----

Build some C code

We want to build a container that compiles a basic "Hello world" program in C.
Here is the program, hello.c:
```c
int main () {
    puts("Hello, world!");
    return 0;
}
```

Let's create a new directory, and put this file in there.

Then we will write the Dockerfile.

----

### The DOCKERFILE
On Debian and Ubuntu, the package build-essential will get us a compiler.
When installing it, don't forget to specify the `-y` flag, otherwise the build will fail (since the build cannot be interactive).
Then we will use COPY to place the source file into the container.

```bash
FROM bitnami/minideb:latest
RUN apt-get update
RUN apt-get install -y build-essential
COPY hello.c /
RUN make hello
CMD /hello
```

----

### Build and test…

Build it
```bash
docker build -t ubuntu_c .
```
Run it
```bash
docker run ubuntu_c
Hello, world!
````

----

### Copy and the build cache
* Run the build again.
* Now, modify hello.c and run the build again.
* Docker can cache steps involving COPY.
* Those steps will not be executed again if the files haven't been changed.

----

### Using LABEL
The `LABEL` instruction adds metadata to an image. A LABEL is a key-value pair. To include spaces within a LABEL value, use quotes and backslashes as you would in command-line parsing. 

A few usage examples:
```
LABEL "com.example.vendor"="ACME Incorporated"
LABEL com.example.label-with-value="foo"
LABEL version="1.0"
LABEL description="This text illustrates \
that label-values can span multiple lines."
```

----

### Using Expose

* The EXPOSE instruction informs Docker that the container listens on the specified network ports at runtime. 
* EXPOSE does not make the ports of the container accessible to the host. To do that, you must use either the -p flag to publish a range of ports or the -P flag to publish all of the exposed ports.

----

### The Dockerfile with EXPOSE

FROM bitnami/minideb:latest
RUN apt-get update && apt-get install -y nginx
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80

* We'll build an image that will run nginx
* We are using the EXPOSE command here to inform what port the container will be listening on.

If we use the -P command, then the EXPOSE port will be used by default and ampped to a random high port on the host.

----

### Testing EXPOSE

* Create the Dockerfile
* Build that image
* run the container
Version1:
```
docker run -d -p 80:80 mynginx
```
Version2:
```
docker run -d -P mynginx
```

The difference can be checked using `docker ps`
To validate that it's working you can use your browser or curl

----

### Using ENV

The ENV instruction sets the environment variable <key> to the value <value>. This value will be in the environment of all “descendant” Dockerfile commands and can be replaced inline in many as well.

----

### Dockerfile with ENV

Create a Dockerfile with this content

```bash
FROM bitnami/minideb:latest
ENV key1 value1
ENV key2=value2
ENV key3="value 3" key4=value\ 4
```
The ENV instruction has two forms. The first form, ENV <key> <value>, will set a single variable to a value. The entire string after the first space will be treated as the <value> - including characters such as spaces and quotes.

The second form, ENV <key>=<value> ..., allows for multiple variables to be set at one time. Notice that the second form uses the equals sign (=) in the syntax, while the first form does not. Like command line parsing, quotes and backslashes can be used to include spaces within values.

----

### Validating ENV

The environment variables set using ENV will persist when a container is run from the resulting image. You can view the values using `docker inspect`, and change them using docker run --env <key>=<value>. Or view them in the container.

```
docker build -t environment .
docker inspect
...
 "Config": {
            "Hostname": "7cbef47bbbe4",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "no_proxy=*.local, 169.254/16",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "key1=value1",
                "key2=value2",
                "key3=value3",
                "key4=key 4"
            ],
...
````

----

### Changing a value

docker run --env key1=value\ 1 environment env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=2230c6cc84e8
key1=value 1
no_proxy=*.local, 169.254/16
key2=value2
key3=value3
key4=key 4
HOME=/root

----

### Checking ENV variable

```
docker run environment env
```
```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=8f45c93ead53
no_proxy=*.local, 169.254/16
key1=value1
key2=value2
key3=value 3
key4=value 4
HOME=/root
```



----

### Uploading our images to the Docker Hub
We have built our first images.
If we were so inclined, we could share those images through the Docker Hub.
We won't do it since we don't want to force everyone to create a Docker Hub account (although it's free, yay!) but the steps would be:
* have an account on the Docker Hub
* tag our image accordingly (i.e. username/imagename)
* docker push username/imagename

Anybody can now docker run username/imagename from any Docker host.

Images can be set to be private as well

----

### Summary

We've learned:
* What an image is
* How to create a Dockerfile
* How to create an image from a Dockerfile
* The usage of `CMD`and `ENTRYPOINT``
* The usage of `COPY`
* The usage of `LABEL`
* The usage of `EXPOSE`
* The usage of `ENV`

----

## Setting up a private registry

In this lesson, I’ll explain:
* How to setup a private registry.
* Ways to secure it.

----

