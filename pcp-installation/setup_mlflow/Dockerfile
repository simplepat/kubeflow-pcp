FROM busybox:1.35.0-uclibc as busybox
FROM python:3.8.0

### START - Airbus specific stuff ###
ENV http_proxy http://ZANNI_A:7NICKnUA24\!@fr0-proxylan-vip.eu.airbus.corp:3128
ENV https_proxy $http_proxy
ENV ftp_proxy $http_proxy
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates
RUN mkdir /usr/local/share/ca-certificates/cacert.org
RUN wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt
COPY airbus-ca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates
### END - Airbus specific stuff ###

# Setup python virtualenv.
RUN echo python3 --version
RUN python3 -m venv env
ENV VIRTUAL_ENV=/home/fbox/env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY pip.conf $VIRTUAL_ENV/pip.conf
ENV PIP_CONFIG_FILE $VIRTUAL_ENV/pip.conf

RUN pip install \
    mlflow==1.26.1 \
        pymysql==1.0.2 \
    boto3 && \
    mkdir /mlflow/


# Now copy the static shell into base image.
COPY --from=busybox /bin/sh /bin/sh
# You may also copy all necessary executables into distroless image.
COPY --from=busybox /bin/mkdir /bin/mkdir
COPY --from=busybox /bin/cat /bin/cat

### START - Airbus specific stuff ###
ENV http_proxy=
ENV https_proxy=
ENV ftp_proxy=
### END - Airbus specific stuff ###

EXPOSE 5000


ENV USERNAME mlflow
ENV PASSWORD 12341234
ENV HOST mlflow-db.kubeflow.svc.cluster.local
ENV PORT 3316
ENV DATABASE mlflow
ENV BUCKET eks-kubeflow-mflow

CMD mlflow server \
    --host 0.0.0.0 \
    --port 5000 \
    --default-artifact-root ${BUCKET} \
    --backend-store-uri mysql+pymysql://${USERNAME}:${PASSWORD}@${HOST}:${PORT}/${DATABASE}
