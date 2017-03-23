## Naming and inspecting containers
In this lesson, we will learn about some important Docker concept: 
* container naming which allows to:
    * Reference easily a container.
    * Ensure unicity of a specific container.
* the inspect command:
    * Gathering details about a container.
* Misc:
    * Cleanup methods

----

### Naming our containers
So far, we have referenced containers with their ID.
We have copy-pasted the ID, or used a shortened prefix.
But each container can also be referenced by its name.
If a container is named prod-db, I can do:
```bash
docker logs prod-db
docker stop prod-db
etc.
```

----

### Default names

When we create a container, if we don't give a specific name, Docker will pick one for us.
It will be the concatenation of:
* A mood (furious, goofy, suspicious, boring...)
* The name of a famous inventor (tesla, darwin, wozniak...)

Examples: happy_curie, clever_hopper, jovial_lovelace ...

----

### Specifying a name
Specifying a name
You can set the name of the container when you create it.
```bash
docker run --name ticktock jpetazzo/clock
```

If you specify a name that already exists, Docker will refuse to create the container.

This enforces unicity of a given name.

----

### Renaming containers
Since Docker 1.5 (released February 2015), you can rename containers with docker rename.   
This allows you to "free up" a name without destroying the associated container, for instance.

----

### Inspecting a container

The `docker inspect` command will output a very detailed JSON map.

```JSON
[
    {
        "Id": "7cbef47bbbe4026ae5b2166454e45208cc29af909f269964721b2633ced2d17a",
        "Created": "2017-01-14T23:12:08.949247863Z",
        "Path": "sleep",
        "Args": [
            "3600"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 15900,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2017-01-14T23:12:09.617372492Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
...
```

----

### Parsing JSON with the shell

You could grep and cut or awk the output of docker inspect.
* But it`s a PITA
* If you really must parse JSON from the Shell, use JQ!
```bash
docker inspect <containerID> | jq .
```

We will see a better solution which doesn't require extra tools.

----

### Using --format
You can specify a format string, which will be parsed by Go's text/template package.
```bash
docker inspect --format '{{ json .Created }}' 7cbef47bbbe4 
"2017-01-14T23:12:08.949247863Z"

docker inspect --format '{{ json .NetworkSettings.IPAddress }}' 7cbef47bbbe4 
"172.17.0.3"

docker inspect --format '{{ json .Config.Env }}' 7cbef47bbbe4 
["no_proxy=*.local, 169.254/16","PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","key1=value1","key2=value2","key3=value3","key4=key 4"]
```

* The generic syntax is to wrap the expression with double curly braces.
* The expression starts with a dot representing the JSON object.
* Then each field or member can be accessed in dotted notation syntax.
* The optional json keyword asks for valid JSON output.  
(e.g. here it adds the surrounding double-quotes.)

----

### Docker cleanup

After working with Docker for some time, you start accumulating development junk: unused volumes, networks, exited containers and unused images.

One command to rule them all:

```
docker system prune
```

`prune` is a very useful command (also works for `volume` and `network` sub-commands), but it is only available for Docker 1.13. So if you’re using older Docker versions, the following commands can help you to replace the prune command.

----

### Removing dangling images

angling volumes are volumes not in use by any container. To remove them, combine two commands: first, list volume IDs for dangling volumes and then remove them.

```
docker rm $(docker volume ls -q -f "dangling=true")
```

----

### Remove Exited containers

The same principle works here too. First, list the containers (only IDs) you want to remove (with filter) and then remove them (consider rm -f to force remove).

```
docker rm $(docker ps -q -f "status=exited")
```

----

### Remove Dangling Images

dangling images are untagged images, that are the leaves of the images tree (not intermediary layers).

```
docker rmi $(docker images -q -f "dangling=true")
```

