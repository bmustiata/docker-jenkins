FROM java:8-jdk

RUN apt-get update && apt-get install -y wget git curl zip graphviz && rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/volume from a data container,
# ensure you use same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

# Jenkins home directoy is a volume, so configuration and build history
# can be persisted and survive image upgrades
# VOLUME /var/jenkins_home

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888

# Use tini as subreaper in Docker container to adopt zombie processes
RUN curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA /bin/tini" | sha1sum -c -

# COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

ENV JENKINS_VERSION 2.8
ENV JENKINS_SHA fda2f13e16b81e1d295696eaf838d60f54f9395c

# could use ADD but this one does not check Last-Modified header
# see https://github.com/docker/docker/issues/8331
RUN curl -fL http://mirrors.jenkins-ci.org/war/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war \
  && echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -

ENV JENKINS_UC https://updates.jenkins-ci.org
RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY plugins.sh /usr/local/bin/plugins.sh

# install docker
RUN wget -O - https://get.docker.com | sh
RUN echo 'DOCKER_OPTS="-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock"' >> /etc/default/docker
RUN usermod -G docker jenkins

RUN chown jenkins:jenkins /usr/local/bin/jenkins.sh && \
	chown jenkins:jenkins /usr/local/bin/plugins.sh && \
	chmod a+x /usr/local/bin/jenkins.sh && \
	chmod a+x /usr/local/bin/plugins.sh

USER jenkins

# Install plugins
COPY plugins.txt /usr/local/etc/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/local/etc/plugins.txt #redo

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
