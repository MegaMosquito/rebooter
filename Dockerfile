FROM python:3-buster

RUN pip3 install schedule

COPY ./rebooter.py /

WORKDIR /
CMD python3 rebooter.py


