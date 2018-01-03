FROM ubuntu
RUN apt-get update && apt-get install -y python python-virtualenv python-pip
ADD . /ansible
WORKDIR /ansible
RUN pip install -r requirements.txt