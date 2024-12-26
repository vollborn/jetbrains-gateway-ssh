FROM ubuntu:latest

LABEL maintainer="vollborn <oliver.vollborn@gmail.com>"
LABEL version="1.1"
LABEL description="A simple ssh server for JetBrains Gateway"

ENV SSH_USERNAME=jetbrains
ENV SSH_PASSWORD=jetbrains

RUN apt-get update && apt-get install -y openssh-server

ADD startup.sh /startup.sh
RUN chmod +x /startup.sh

VOLUME [ "/opt/home" ]
WORKDIR /opt/home

EXPOSE 22

ENTRYPOINT [ "bash" ]
CMD [ "/startup.sh" ]
