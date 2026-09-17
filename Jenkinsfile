pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'bishnu2000'
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        IMAGE_NAME = 'devops-build'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        sh "docker build -t ${DOCKERHUB_USER}/dev:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKERHUB_USER}/dev:${BUILD_NUMBER} ${DOCKERHUB_USER}/dev:latest"
                    }

                    if (env.BRANCH_NAME == 'main') {
                        sh "docker build -t ${DOCKERHUB_USER}/prod:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKERHUB_USER}/prod:${BUILD_NUMBER} ${DOCKERHUB_USER}/prod:latest"
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: "${DOCKERHUB_CREDENTIALS}",
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {

                        sh '''
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
                        '''

                        if (env.BRANCH_NAME == 'dev') {
                            sh "docker push ${DOCKERHUB_USER}/dev:${BUILD_NUMBER}"
                            sh "docker push ${DOCKERHUB_USER}/dev:latest"
                        }

                        if (env.BRANCH_NAME == 'main') {
                            sh "docker push ${DOCKERHUB_USER}/prod:${BUILD_NUMBER}"
                            sh "docker push ${DOCKERHUB_USER}/prod:latest"
                        }

                        sh 'docker logout'
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for branch: ${BRANCH_NAME}"
        }

        failure {
            echo "Pipeline failed for branch: ${BRANCH_NAME}"
        }
    }
}
