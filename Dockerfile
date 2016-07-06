FROM jenkinsci/jenkins:2.11

ENV BLUEOCEAN_VERSION=c16c0c597a7cd1a4051901e039614d01f807853e

RUN mkdir /tmp/blueocean-build && \
    cd /tmp/blueocean-build && \
    wget http://mirror.klaus-uwe.me/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    tar -zxvf apache-maven-3.3.9-bin.tar.gz && \
    export PATH="/tmp/blueocean-build/apache-maven-3.3.9/bin:$PATH" && \
    git clone https://github.com/jenkinsci/blueocean-plugin && \
    cd blueocean-plugin && \
    git checkout $BLUEOCEAN_VERSION && \
    mvn -Dmaven.repo.local=/tmp/blueocean-build/_m2 install -DskipTests && \
    mkdir /tmp/blueocean && \
    cp blueocean-*/target/*.hpi /tmp/blueocean && \
    rm -fr /tmp/blueocean-build && \
    mv /tmp/blueocean/blueocean.hpi /tmp/blueocean/blueocean-plugin.hpi

USER root

RUN apt-get update && \
    apt-get install -y wget git mercurial zip graphviz && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/jenkins/ref/plugins/ && \
    mv /tmp/blueocean/*.hpi /usr/share/jenkins/ref/plugins/

ENV JENKINS_HOME /var/jenkins_home

# install docker
RUN wget -O - https://get.docker.com | sh
RUN echo 'DOCKER_OPTS="-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock"' >> /etc/default/docker
RUN usermod -G docker jenkins

# Install the plugins using jenkins itself.
RUN cd /usr/share/jenkins/ref/plugins/; \
	install-plugins.sh \
        analysis-core \
        ansicolor \
        blueocean \
        blueocean-commons \
        blueocean-events \
        blueocean-rest-impl \
        blueocean-web \
        blueocean-dashboard \
        blueocean-personalization \
        blueocean-rest \
        build-timeout \
        build-metrics \
        credentials \
        credentials-binding \
        cucumber-reports \
        cucumber-testresult-plugin \
        dashboard-view \
        dependency-check-jenkins-plugin \
        description-setter \
        docker-plugin \
        envinject \
        extended-read-permission \
        gerrit-trigger \
        git \
        git-client \
        gitlab-plugin \
        git-server \
        global-build-stats \
        gravatar \
        greenballs \
        groovy-postbuild \
        jobConfigHistory \
        jquery \
        junit \
        ldap \
        m2release \
        mailer \
        mask-passwords \
        matrix-auth \
        matrix-project \
        mercurial \
        naginator \
        nodelabelparameter \
        pam-auth \
        parameterized-trigger \
        plain-credentials \
        PrioritySorter \
        rebuild \
        release \
        scm-api \
        scoverage \
        script-security \
        subversion \
        swarm \
        throttle-concurrents \
        timestamper \
        token-macro \
        view-job-filters \
        workflow-aggregator \
        ws-cleanup

# Force use of latest blueocean plugin, until this one is published and users can rely on update center for updates
RUN for f in /usr/share/jenkins/ref/plugins/blueocean*.hpi; do mv "$f" "$f.override"; done

# Disable the upgrade wizard
RUN echo -n 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state  && \
    echo -n 2.0 > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

USER jenkins

