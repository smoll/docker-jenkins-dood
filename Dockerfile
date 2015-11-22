############################
# Jenkins with CloudBees Docker Workflow and Jenkins Job DSL Plugins
# Used as the base image for smoll/jenkins-dood
############################

FROM jenkins:latest
MAINTAINER Shujon Mollah <mollah@gmail.com>

#
# Install plugins
#
USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
