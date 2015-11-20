############################
# Jenkins with CloudBees Docker Workflow and Jenkins Job DSL Plugins
# Used as the base image for smoll/jenkins-dood
############################

FROM jenkins:latest
MAINTAINER Shujon Mollah <mollah@gmail.com>

#
# The plugins we want
#
COPY plugins.txt /usr/share/jenkins/plugins.txt
