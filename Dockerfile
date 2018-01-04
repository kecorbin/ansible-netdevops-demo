FROM ubuntu
RUN apt-get update && apt-get install -y python python-virtualenv python-pip
ADD ./requirements.txt /ansible/
WORKDIR /ansible
RUN pip install -r requirements.txt
# https://gitlab.com/gitlab-org/gitlab-runner/issues/1170
ENTRYPOINT []
