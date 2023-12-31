.PHONY: build run remove restart clean rebuild prompt prune
# Base distribution
distro := archlinux
# Image name
img := $(distro):local-devel
# Volume name
vol := $(distro)-vol
build:
	-docker volume create $(vol)
	@read -p "Enter a username for the image: " username; \
	stty -echo; \
	read -p "Enter a password for the image: " password; \
	stty echo; \
	echo; \
	docker build $(distro) --build-arg username=$$username --build-arg password=$$password -t $(img)
run:
	mkdir ${HOME}/workplace/ || echo "Workplace directory already exists. Not creating."
	@read -p "Enter the username you used to build the image: " username; \
	if [ $$(docker ps -q -f name=$(distro)) ]; then \
		echo "Container $(distro) is running. Attaching..."; \
		docker exec -it $(distro) /bin/zsh; \
	elif [ $$(docker ps -aq -f status=exited -f name=$(distro)) ]; then \
		echo "Container $(distro) exists but stopped. Starting and attaching..."; \
		docker start $(distro); \
		docker attach $(distro); \
	else \
		echo "Container does not exist. Running..."; \
		docker run \
			--name $(distro) \
			-h $(distro) \
			-v ${HOME}/workplace/:/home/$$username/workplace \
			-v $(vol):/home/$$username \
			-v "//var/run/docker.sock://var/run/docker.sock" \
			-v ${HOME}:/home/$$username/host/ \
			-p 3000-3005:3000-3005 \
			-it $(img); \
	fi
remove:
	-docker ps -a -q --filter "name=$(distro)" | xargs -r docker rm
restart: remove run
clean: remove 
	-docker rmi $(img)
	docker builder prune -f
rebuild: clean build
prompt:
	@read -p "WARNING: This will remove any files you have created in the Docker volume which are not synced to your host. Continue? [y/N]: " CONTINUE; \
	if [ "$$CONTINUE" != "y" ] && [ "$$CONTINUE" != "Y" ]; then \
		echo "Exiting"; \
		exit 1; \
	fi
prune: prompt clean
	-docker volume rm $(vol)
