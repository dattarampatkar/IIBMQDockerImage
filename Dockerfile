# Dockerfile for installing iib alongside MQ
# https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/linuxx64_odbc_cli.tar.gz  for the DB2 client

FROM ubuntu:14.04

MAINTAINER Peter Weismann Peter.Weismann@yandex.com

# Update repository, install curl, bash, bc, rpm, tar packages
RUN apt-get update && \
    apt-get install -y curl bash bc rpm tar wget libxml2 unixodbc-dev unixodbc-bin unixodbc rsyslog && \
    rm -rf /var/lib/apt/lists/*

# Copy startup script which invokes the MQ & IIB startup scripts and make it executable
COPY setenv.sh /usr/local/bin/
COPY execute_startup_scripts.sh /usr/local/bin/
COPY gen_instance_number.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/execute_startup_scripts.sh
RUN chmod a+rx /usr/local/bin/gen_instance_number.sh
RUN chmod a+rx /usr/local/bin/setenv.sh

###############################################################    
# update syslog-ng client 
###############################################################    
# Create user to run as on syslog-ng server only
#RUN groupadd nglogs
#RUN useradd --create-home --home-dir /home/log1 -G nglogs log1

#Configure syslog-ng
#RUN cp /etc/syslog-ng/syslog-ng.conf /usr/local/bin/syslog-ng.conf.bkup
#RUN cp /etc/syslog-ng/scl.conf /usr/local/bin/scl.conf.bkup
#RUN cp /etc/default/syslog-ng /usr/local/bin/syslog-ng.bkup

# COPY key files
#COPY syslog-ng/syslog-ng.sh /usr/local/bin/
#COPY syslog-ng/clientConfig.sh /usr/local/bin/
#COPY syslog-ng/client.conf /etc/syslog-ng/conf.d/

#RUN chmod a+rx /usr/local/bin/syslog-ng.sh
#RUN chmod a+rx /usr/local/bin/clientConfig.sh
#RUN sudo chmod 644 /etc/syslog-ng/conf.d/client.conf

###############################################################    
# MQ: Copy all needed scripts to image and make them executable
###############################################################    
#COPY MQ/mq.sh /usr/local/bin/
#COPY MQ/mq-license-check.sh /usr/local/bin/
COPY MQ/*.sh /usr/local/bin/
COPY MQ/*.mqsc /etc/mqm/
RUN chmod a+rx /usr/local/bin/*.sh 

###############################################################    
# IIB: Copy all BAR files for deployment
###############################################################    
COPY IIB/bars/*.bar /tmp/


# Install MQ Developer Edition
RUN export DEBIAN_FRONTEND=noninteractive \
  # The URL to download the MQ installer from in tar.gz format
  && MQ_URL=http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev80_linux_x86-64.tar.gz \
  # The MQ packages to install
  && MQ_PACKAGES="MQSeriesRuntime-*.rpm MQSeriesServer-*.rpm MQSeriesMsg*.rpm MQSeriesJava*.rpm MQSeriesJRE*.rpm MQSeriesGSKit*.rpm MQSeriesSamples-*.rpm" \
  # Optional: Update the command prompt
  && echo "mq:8.0" > /etc/debian_chroot \
  # Download and extract the MQ installation files
  && mkdir -p /tmp/mq \
  && cd /tmp/mq \
  && curl -LO $MQ_URL \
  && tar -zxvf ./*.tar.gz \
  # Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
  && groupadd mqm \
  && useradd --gid mqm --home-dir /var/mqm mqm \
  && usermod -G mqm root \
  && cd /tmp/mq/MQServer \
  # Accept the MQ license
  && ./mqlicense.sh -text_only -accept \
  # Install MQ using the RPM packages
  && rpm -ivh --force-debian $MQ_PACKAGES \
  # Recommended: Set the default MQ installation (makes the MQ commands available on the PATH)
  && /opt/mqm/bin/setmqinst -p /opt/mqm -i \
  # Clean up all the downloaded files
  && rm -rf /tmp/mq \
  && rm -rf /var/lib/apt/lists/*
  
###############################################################    
# IIB: Copy all needed scripts to image and make them executable
###############################################################    
COPY IIB/kernel_settings.sh /tmp/
#COPY IIB/iib_manage.sh /usr/local/bin/
#COPY IIB/iib-license-check.sh /usr/local/bin/
#COPY IIB/iib_env.sh /usr/local/bin/
#COPY IIB/genodbcini.sh /usr/local/bin/

COPY IIB/*.sh /usr/local/bin/
COPY IIB/odbc.template /usr/local/bin/

COPY IIB/jar/*.jar /usr/local/bin/
COPY IIB/certificate/*.cer /usr/local/bin/
COPY IIB/certificate/*.jks /usr/local/bin/

RUN chmod a+rx /tmp/kernel_settings.sh
RUN chmod a+rx /usr/local/bin/*.sh

# Install IIB V10 Developer edition
RUN mkdir /opt/ibm && \
    curl http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/10.0.0.3-IIB-LINUX64-DEVELOPER.tar.gz \
    | tar zx --directory /opt/ibm --exclude='tools' && \
    /opt/ibm/iib-10.0.0.3/iib make registry global accept license silently

# Configure system
RUN echo "IIB_10:" > /etc/debian_chroot  && \
    touch /var/log/syslog && \
    chown syslog:adm /var/log/syslog && \
    /tmp/kernel_settings.sh

# Create user to run as
RUN useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo iibuser && \
    sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers 
RUN groupadd mqusers
RUN useradd --create-home --home-dir /home/iibpoc01 -G mqusers iibpoc01

# create required env variables for iib user profile
RUN echo "#!/bin/bash" > /home/iibuser/.bash_profile && \
		echo ". /usr/local/bin/setenv.sh" >> /home/iibuser/.bash_profile && \
    	sed -e "$ a . /opt/ibm/iib-10.0.0.3/server/bin/mqsiprofile " -i /home/iibuser/.bash_profile

############################################################### 
# Install DB2 CLI Driver required for dashdb service
###############################################################    
COPY IIB/db2driver/v10.5fp5_linuxx64_odbc_cli.tar.gz /tmp/
RUN mkdir /opt/db2cli && \
	cd /opt/db2cli && \
    cp /tmp/v10.5fp5_linuxx64_odbc_cli.tar.gz /opt/db2cli/ && \
	tar -zxvf ./*.tar.gz && \
	rm -rf *.tar.gz

RUN cat /etc/sudoers > /tmp/sudoers 

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
ENV BASH_ENV=/usr/local/bin/iib_env.sh

# Expose default admin port and http port
EXPOSE 514 1414 4414 7800 9080 9443

#USER iibuser

# Always put the IIB and MQ data directory in a Docker volume
VOLUME /var/mqm
VOLUME /var/mqsi

# Run mq & iib setup scripts
ENTRYPOINT ["/bin/sh", "-c", "execute_startup_scripts.sh"]
