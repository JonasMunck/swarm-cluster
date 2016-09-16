# FROM gliderlabs/alpine:3.1
FROM python:2.7

EXPOSE 5000
CMD ["python", "app.py"]

RUN pip install flask

ADD . /code
WORKDIR /code

#RUN apk-install python \
#    python-dev \
#    py-pip &&\
#    pip install -r requirements.txt
