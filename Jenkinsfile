pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/Guy-BP/Project_RedTeam.git'
        SERVER_IMAGE_NAME = 'reactapp_server:v1'
        FRONT_IMAGE_NAME = 'reactapp_front:v1'
        PYTEST_IMAGE_NAME = 'reactapp_pytest:v1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: REPO_URL]]])
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    docker.build(SERVER_IMAGE_NAME, './server')
                    docker.build(FRONT_IMAGE_NAME, './frontend')
                    docker.build(PYTEST_IMAGE_NAME, './test')
                }
            }
        }

        stage('Run Containers') {
            agent {
                any {
                    image 'docker'
                    args '-u root'
                }
            }
            steps {
                script {
                    def serverContainer = docker.image(SERVER_IMAGE_NAME).run('-p 3001:3001 -d')
                    def frontContainer = docker.image(FRONT_IMAGE_NAME).run('-p 3000:3000 -d')

                    def pytestContainer = docker.image(PYTEST_IMAGE_NAME).run()

                    def pytestExitCode = pytestContainer.waitForCondition(20, TimeUnit.SECONDS) { container -> container.exitCode }

                    serverContainer.stop()
                    serverContainer.remove(force: true)
                    frontContainer.stop()
                    frontContainer.remove(force: true)
                    pytestContainer.remove(force: true)

                    if (pytestExitCode != 0) {
                        error("Pytest failed with exit code: ${pytestExitCode}")
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
