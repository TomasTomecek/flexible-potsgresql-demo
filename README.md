# Flexible PostgreSQL container image demo

This repository demonstrates an ability to extend PostgreSQL container image:

```
registry.access.redhat.com/rhscl/postgresql-95-rhel7:latest
```

The effort of extending images is focused on these aspects:

 * container image to provide API for extending it (might be covered just by documentation)
 * container image upstream to create tests which validate the extending process
 * container image provides documentation including real examples how to perform the extending process


## The demo

*As a user of PostgreSQL container, I want to provide my own configuration file so I can precisely configure the service.*

It's not easy to do what the user story above states. Especially because:

 1. As a user, you have no idea how the service is installed within a container image.
   * This is way more complicated with Software Collections -- is the config in `/etc` or `/opt`?

 2. Container image is black-box with clearly defined API.
   * If the API is not set, then it's just trial & error while hoping it would work with next update.

 3. If I mount a config, will the entrypoint script process it correctly?
   * Even worse: do I need to read and understand how the entrypoint script works?


If we start offering a way to extend images as an API, then everyone will be able to configure the containerized services easily. So let's proceed with the demo.

If the PostgreSQL container image explicitly specified that

```
# Supplying custom configuration file

You are able to supply your custom configuration file. PostgreSQL container image is using templating to fill in configuration file in container startup script. You are able to override the default template. With this approach you can even define your own variables which you can pass as envinronment variables to the container.

The template is located within container image on path:

    /usr/share/container-scripts/postgresql/openshift-custom-postgresql.conf.template

You can copy it like this:

    $ docker create --name=pg registry.access.redhat.com/rhscl/postgresql-95-rhel7:latest
    $ docker cp pg:/usr/share/container-scripts/postgresql/openshift-custom-postgresql.conf.template .

And then file `openshift-custom-postgresql.conf.template` will be present in your current working directory.

For more information on the configuration file, please see [the man page](TBD).
```

With this information, we can easily supply our own config.

So we copied the default template config and added a way to set `work_mem` by appending these lines to the config:

```

# Let’s increase work_mem so most operations are performed in memory
work_mem = ${POSTGRESQL_WORK_MEM}
```

and then, we can change the `work_mem` parameter by specifying it as en envinronment variable:

```
docker run --rm \
	-v openshift-custom-postgresql.conf.template:/usr/share/container-scripts/postgresql/ \
	-e POSTGRESQL_WORK_MEM=128MB \
	...
```

### Workflow

Let's get through the real demo. Clone this repository first:

```
$ git clone https://github.com/TomasTomecek/flexible-postgresql-demo
$ cd flexible-postgresql-demo
```

We will continue with pulling the upstream image `registry.access.redhat.com/rhscl/postgresql-95-rhel7:latest`:

```
$ make pull-upstream-image
```

We would now copy the default template configuration file. It's already present in the repository so you can check it out (it already contains the `work_mem` cheanges).

```
$ cat ./openshift-custom-postgresql.conf.template
```

You can also inspect make rule to obtain the file (`make openshift-custom-postgresql.conf.template`).

We can now run postgres and change `work_mem` to `128M`:

```
$ make inject
```

Let's inspect the runtime configuration of our containerized postgres:

```
$ make show-work-mem
```
