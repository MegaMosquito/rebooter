
DOCKERHUB_ID:=ibmosquito
NAME:="rebooter"
VERSION:="1.0.0"

default: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(NAME):$(VERSION) .

dev: stop build
	docker run -it -v `pwd`:/outside \
	  --name ${NAME} \
	  --privileged \
	  --cap-add CAP_SYS_BOOT \
	  -v /bin/systemctl:/bin/systemctl \
	  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	  -v /var/run/systemd:/var/run/systemd \
	  -v /var/run/dbus:/var/run/dbus \
	  -v /etc/localtime:/etc/localtime \
	  $(DOCKERHUB_ID)/$(NAME):$(VERSION) /bin/sh

run: stop
	docker run -d \
	  --name ${NAME} \
	  --restart unless-stopped \
	  --privileged \
	   --cap-add CAP_SYS_BOOT \
	  -v /bin/systemctl:/bin/systemctl \
	  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	  -v /var/run/systemd:/var/run/systemd \
	  -v /var/run/dbus:/var/run/dbus \
	  -v /etc/localtime:/etc/localtime \
	  $(DOCKERHUB_ID)/$(NAME):$(VERSION)

test:
	@echo "test"

push:
	docker push $(DOCKERHUB_ID)/$(NAME):$(VERSION) 

stop:
	@docker rm -f ${NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(NAME):$(VERSION) >/dev/null 2>&1 || :

.PHONY: build dev run push test stop clean
