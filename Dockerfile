FROM python:3.8-alpine

RUN mkdir /data
COPY . /data/
WORKDIR /data

RUN pip install cffconvert
CMD ["cffconvert", "--help"]
