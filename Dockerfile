############################
# Jenkins with DooD
# Based on: http://container-solutions.com/2015/03/running-docker-in-jenkins-in-docker/
############################

FROM jenkins:latest
MAINTAINER Alejandro Ricoveri <alejandroricoveri@gmail.com>

#
# Install necessary packages
#
USER root
RUN apt-get update \
      && apt-get install -y sudo supervisor \
      && rm -rf /var/lib/apt/lists/*

#
# Give sudo privileges to jenkins
#
RUN echo "jenkins ALL=NOPASSWD: /bin/docker.io" >> /etc/sudoers

#
# The sudo workaround
#
COPY docker.sh /usr/bin/docker
RUN chmod +x /usr/bin/docker

#
# Install initial plugins
#
USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

#
# supervisord
#
USER root

# Create log folder for supervisor and jenkins
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/log/jenkins

# Copy the supervisor.conf file into Docker
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Give "master" node the "docker" label, for use by Docker Workflow plugin
COPY customize/label.groovy /usr/share/jenkins/ref/init.groovy.d/label.groovy

# Start supervisord when running the container
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
