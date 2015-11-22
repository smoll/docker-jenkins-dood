build:
	@docker-compose build

run:
	@docker-compose up -d

kill:
	@docker-compose kill

clean:	kill
	@docker-compose rm jenkinsmaster

clean-data:	kill
	@docker-compose rm -v jenkinsmaster

clean-images:
	@docker rmi $(docker images -q --filter="dangling=true")
