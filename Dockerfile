FROM centos:7

LABEL maintainer="bonju0102"

ENV URL="rtsp://" \
    WS_PORT=8082

COPY ./entrypoint.sh /usr/local/bin/

## Dependencies layer
RUN \
  # Enable the EPEL repo. The repo package is part of centos base so no need fetch it.
  yum -y install epel-release \
  # Fetch and enable the RPMFusion repo
  && yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm \
  # Fetch and enable the NodeSource repo
  && curl -sL https://rpm.nodesource.com/setup_10.x | /bin/bash - \
  # Install dependencies
  && yum -y install ffmpeg ffmpeg-devel nodejs unzip \
  # Clean up yum cache
  && yum clean all \
  # Download JSMpeg
  && curl https://github.com/phoboslab/jsmpeg/archive/master.zip -Lo /tmp/jsmpeg-master.zip \
  && unzip /tmp/jsmpeg-master.zip -d /home/ \
  && rm /tmp/jsmpeg-master.zip \
  # Make sure the entrypoint is executable
  && chmod 755 /usr/local/bin/entrypoint.sh

RUN \
  cd /home/jsmpeg-master/ \
  # Install Websocket & http-server package
  && npm install ws \
  && npm install http-server -g

# Expose Websocket port
EXPOSE ${WS_PORT}

# This is run each time the container is started
ENTRYPOINT /usr/local/bin/entrypoint.sh ${URL} ${WS_PORT}