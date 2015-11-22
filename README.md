![](http://i.imgur.com/KC6TAD3.png)
[WIP] Jenkins with DooD (Docker outside of Docker), CloudBees Docker Workflow and Jenkins Job DSL
---
A [Jenkins image](https://registry.hub.docker.com/_/jenkins/) capable of using [Docker](http://docker.com), so you can Docker while you Docker (`smoll/jenkins-dood`) for use locally, and a generic Dockerized Jenkins (`smoll/jenkins`) for use on a shared server, and connected to Docker cloud slaves.

* [Rationale](#rationale)
* [What about secrets?](#what-about-secrets)
* [Plugins](#plugins)
* [Structure](#structure)
* [Example Compose YMLs](#example-compose-ymls)

## First of all, WTF is *DooD* supposed to mean?
See [axltxl/docker-jenkins-dood](https://github.com/axltxl/docker-jenkins-dood#first-of-all-wtf-is-dood-supposed-to-mean) for more info.

## Rationale
This was forked from [axltxl/docker-jenkins-dood](https://github.com/axltxl/docker-jenkins-dood) in order to make a few customizations so it more closely mirrors my desired "Productionized" Docker in CI setup, namely:
* A "dumb" Jenkins master server, which has nothing but Jenkins on it
* Jenkins slaves, which have nothing but Docker on them
* CloudBees Docker Workflow plugin installed on the master, which allows you to run stuff on a Jenkins slave Docker host with a simple DSL

A good treatise on the plugin can be found [here](https://www.cloudbees.com/blog/orchestrating-workflows-jenkins-and-docker-0):

> What if all this hassle just went away? Let us say the Jenkins administrators guaranteed one thing only:
>
> > If you ask to build on a slave with the label docker, then Docker will be installed.
>
> and proceeded to attach a few dozen beefy but totally plain-vanilla Linux cloud slaves. Finally with CloudBees Docker Workflow you can use these build servers as they come.
> ```groovy
// OK, here we come
node('docker') {
    // My project sources include both build.xml and a Dockerfile to run it in.
    git 'https://git.mycorp.com/myproject.git'
    // Ready?
    docker.build('mycorp/ant-qwerty:latest').inside {
        sh 'ant dist-package'
    }
    archive 'app.zip'
}
```
> That is it.

In the case of `smoll/jenkins-dood`, the master is *itself* the "slave with the label docker." For `smoll/jenkins` it's expected that you manually connect a few "beefy but totally plain-vanilla Linux cloud slaves."

The idea behind these 2 Docker images is they facilitate us committing the Jenkins Job config to version control.

## What about secrets?
**Q: If all of our job configuration is in source control, where do secrets go?**

A: Try one of these:
  * [credstash](https://github.com/fugue/credstash)
  * [confidant](https://github.com/lyft/confidant)
  * [vault](https://github.com/hashicorp/vault)

## Plugins
Since there is no dependency resolution done by the plugin installer script, we need to figure out every single plugin that needs to be installed. The way I do this is:

0. Manually install all the plugins that I want installed
0. `grep -r "Short-Name: " /var/jenkins_home/plugins`
0. Add the plugins from the list that I really want as `pluginx:latest` and their dependencies as: `plugindep` (without `:latest`) to `plugins.txt`.

## Structure
I'm using `.shipwright.json` to organize shipping Docker images to the Docker Hub; it maps subdirectories to docker image names. It can also tag images by branch name, but I'm not using that feature -- I'm only pushing a new image once code is merged to `master`.

* `smoll/jenkins:master` - uses `FROM jenkins:latest`, augmented with 2 key plugins: CloudBees Docker Workflow, and Jenkins Job DSL

* `smoll/jenkins-dood:master` - uses `FROM smoll/jenkins:master` as its base image. It's expected for the host's Docker executable and daemon socket to be mounted when this container is run.

## Example Compose YMLs
* `examples/local.yml` - Sample Docker Compose YML suitable for spinning up a local Jenkins box. Because `smoll/jenkins-dood:master` labels the Jenkins master with the "docker" label, it is treated as a generic Docker host, and will spin up sibling containers.

* `examples/org.yml` - Sample Docker Compose YML suitable for spinning up a "Productionized" Jenkins box, for shared use by a Development team. You still need to manually connect a few beefy but generic cloud slaves to it, so that it can run scripts that specify `node('docker') { sh 'echo etc' }`. This master is *NOT* labeled with the "docker" label.
