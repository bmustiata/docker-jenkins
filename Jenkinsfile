
def dockerImageName
def germaniumImageName

stage('Build Container') {
    def parallelContainers = [:]

    parallelContainers."Jenkins" = {
        node {
            deleteDir()

            checkout scm

            dockerImageName = "jenkins_${gitHash(10)}"

            dockerBuild file: './Dockerfile',
               tags: [dockerImageName]
        }
    }

    parallelContainers."Germanium" = {
        node {
            deleteDir()

            checkout scm

            germaniumImageName = "jenkins_ge_${gitHash(10)}"

            dockerBuild file: './Dockerfile.ge',
                tags: [germaniumImageName]
        }
    }

    parallel(parallelContainers)
}

stage('Test Container') {
    node {
        deleteDir()

        checkout scm

        dockerImageName = "jenkins_${gitHash(10)}"
        germaniumImageName = "jenkins_ge_${gitHash(10)}"

        try {
            dockerRun image: dockerImageName,
                name: dockerImageName,
                remove: true,
                daemon: true

            dockerRun image: germaniumImageName,
                env: [
                    "JENKINS_URL=http://${dockerImageName}:8080/"
                ],
                links: [
                    dockerImageName
                ]
                remove: true
        } finally {
            dockerRm containers: [
                dockerImageName,
                germaniumImageName
            ]
        }
    }
}

