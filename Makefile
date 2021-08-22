
DOCKERHUB_ID:=ibmosquito
NAME:="rebooter"
VERSION:="1.0.0"

# When to do the daily reboot
WHEN:="03:00"

default: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(NAME):$(VERSION) .

dev: stop build
	docker run -it -v `pwd`:/outside \
	  -e WHEN="${WHEN}" \
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
	  -e WHEN="${WHEN}" \
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

# Set the WHEN to reboot to 2 minutes from right now
MIN=$(shell date +"%M")
MIN2=$(shell expr ${MIN} \+ 2)
MINUTE=$(shell expr ${MIN2} \% 60)
HR=$(shell date +"%H")
HR1=$(shell expr ${HR} \+ 1)
HR1M=$(shell expr ${HR1} \% 24)
HOUR=$(shell if [ ${MIN2} -gt 60 ] ; then echo "${HR1M}"; else echo "${HR}"; fi)
TESTWHEN=$(shell printf '%02d:%02d' ${HOUR} ${MINUTE})
#chk:
#	echo "${MIN} ${MIN2} ${MINUTE} ${HR} ${HR1M} ${HOUR} ${WHEN}"
test: stop
	docker run -d \
	  -e WHEN="${TESTWHEN}" \
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

push:
	docker push $(DOCKERHUB_ID)/$(NAME):$(VERSION) 

stop:
	@docker rm -f ${NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(NAME):$(VERSION) >/dev/null 2>&1 || :

.PHONY: build dev run push test stop clean
