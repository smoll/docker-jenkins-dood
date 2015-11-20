![](http://i.imgur.com/KC6TAD3.png)
[WIP] Jenkins with DooD (Docker outside of Docker), with JNLP slave
---

A Jenkins master and slave, each running in a Docker container, with the slave capable of starting Docker.

[WTF does DooD mean?](https://github.com/axltxl/docker-jenkins-dood)

## How to use this
### Write your own docker-compose.yml
```yaml
master:
  image: smoll/jenkins-dood
  volumes:
   - ${which docker}:/bin/docker.io
   - /var/run/docker.sock:/var/run/docker.sock
   - /var/jenkins_home:/var/jenkins_home
  ports:
   - 8080:8080

slave:
  image: smoll/jnlp-slave-dood
  environment:
   - JENKINS_URL=$${MASTER_PORT_8080_HTTP}
  links:
   - master
```

## Why?

I wanted to be able to spin up a Jenkins instance that more closely mirrored my desired "Productionized" Docker setup, namely:

* A "dumb" Jenkins master server, which has nothing but Jenkins on it
* Jenkins slaves with Docker and only Docker installed
* CloudBees Docker Workflow plugin installed on the master, which allows you to run stuff on a Jenkins slave Docker host with a simple DSL.

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
