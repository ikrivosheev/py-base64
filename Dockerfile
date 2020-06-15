FROM python:3.7-stretch

WORKDIR /build
RUN apt-get update && apt-get install -y cmake
COPY . .
RUN pip install -U pip setuptools wheel
RUN pip install -r requirements.txt
RUN python setup.py build_cmake install
RUN python setup.py test
