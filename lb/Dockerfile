FROM nginx:latest

RUN apt-get update
RUN apt-get install -y vim unzip

ADD https://releases.hashicorp.com/consul-template/0.12.2/consul-template_0.12.2_linux_amd64.zip /usr/bin/
RUN unzip -d /usr/local/bin  /usr/bin/consul-template_0.12.2_linux_amd64.zip

# ENTRYPOINT ["/start.sh"]
EXPOSE 80

ENV CONSUL_URL http://192.168.99.101:8500  # consul-template handles allocation of ip address

ADD start.sh /start.sh

COPY service.ctmpl /service.ctmpl
# ADD simple.ctmpl /simple.ctmpl

RUN rm -v /etc/nginx/conf.d/*.conf
RUN chmod 777 /start.sh
