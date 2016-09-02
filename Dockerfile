FROM jenkinsci/jenkins:2.20

USER root

RUN apt-get update && \
    apt-get install -y wget git mercurial zip graphviz && \
    rm -rf /var/lib/apt/lists/*

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

# Disable the upgrade wizard
RUN echo -n 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state  && \
    echo -n 2.0 > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

RUN chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

USER jenkins

