pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t guy66bp/appserver ./server'
                sh 'docker build -t guy66bp/appfront ./frontend'
            }
        }
        stage('Deploy Containers') {
            steps {
                sh 'docker run -d -p 3001:3001 guy66bp/appserver'
                sh 'sleep 5' // Give the container some time to start up
                sh 'docker run -d -p 3000:3000 guy66bp/appfront'
                sh 'sleep 5' // Give the container some time to start up
            }
        }
        stage('Run Tests') {
            steps {
                sh 'python3 -m pytest --junitxml=testresault.xml test/test.py'
            }
        }
        stage('Login and Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_USER', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin'
                    sh 'docker push guy66bp/appserver'
                    sh 'docker push guy66bp/appfront'
                }
            }
        }
        stage('Remove images') {
            steps {
                sh 'docker kill $(docker ps -q)'
                sh 'docker rmi -f guy66bp/appserver'
                sh 'docker rmi -f guy66bp/appfront'
            }
        }
        stage('TF init&plan') {
            steps {
                sh 'AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)'
                sh 'AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)'
                sh 'terraform init'
                sh 'terraform plan'
            }
        }
        stage('TF Approval') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }

        success {
            echo "Tests passed, pipeline succeeded!"
            cleanUpContainers()
        }
        failure {
            echo "Tests failed, pipeline failed!"
            cleanUpContainers()
        }
    }
}
