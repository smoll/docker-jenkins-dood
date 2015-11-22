# Makefile for development of these Docker images

build:
	@shipwright

local:	build
	@docker run -d -v `which docker`:/bin/docker.io \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/jenkins_home \
		-p 50000:50000 \
		-p 8080:8080 \
		smoll/jenkins-dood:latest >> .makelog

org:	build
	@docker run -d \
		-p 50001:50000 \
		-p 8081:8080 \
		smoll/jenkins:latest >> .makelog

push:
	@shipwright push

purge:
	@shipwright purge

clean:
	@< .makelog xargs -I % sh -c 'docker kill %; docker rm -v %'
	@rm -f .makelog

.DEFAULT_GOAL := build
