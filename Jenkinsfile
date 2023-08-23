pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/Guy-BP/Project_RedTeam.git'
        SERVER_IMAGE_NAME = 'guy66bp/reactapp_server'
        FRONT_IMAGE_NAME = 'guy66bp/reactapp_front'
        PYTEST_IMAGE_NAME = 'guy66bp/reactapp_pytest'
    }

    options {
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: REPO_URL]]])
            }
        }

        stage('Run Server and Front Containers') {
            agent any
            steps {
                catchError(buildResult: 'FAILURE') {
                    script {
                        def serverContainer = docker.image(SERVER_IMAGE_NAME).run('-p 3001:3001 -d')
                        def frontContainer = docker.image(FRONT_IMAGE_NAME).run('-p 3000:3000 -d')

                        try {
                            sh 'sleep 15'

                            def pytestContainer = docker.image(PYTEST_IMAGE_NAME).run('-it', '--rm')

                            try {
                                def pytestExitCode = pytestContainer.waitForCondition(10, TimeUnit.SECONDS) { container -> container.exitCode }

                                if (pytestExitCode != 0) {
                                    error("Pytest failed with exit code: ${pytestExitCode}")
                                }
                            } finally {
                                pytestContainer.stop()
                                pytestContainer.remove(force: true)
                            }
                        } finally {
                            frontContainer.stop()
                            frontContainer.remove(force: true)
                            serverContainer.stop()
                            serverContainer.remove(force: true)
                        }
                    }
                }
            }
        }
    }
}


