FROM ubuntu:latest

LABEL maintainer="vollborn <oliver.vollborn@gmail.com>"
LABEL version="1.0"
LABEL description="A simple ssh server for JetBrains Gateway"

ENV SSH_USERNAME=jetbrains
ENV SSH_PASSWORD=jetbrains

ADD startup.sh /startup.sh

RUN apt-get update && apt-get upgrade -y && \
	apt-get install openssh-server -y && \
	systemctl enable ssh && \
	chmod +x /startup.sh

VOLUME [ "/opt/home" ]
WORKDIR /opt/home

EXPOSE 22

CMD [ "/startup.sh" ]
