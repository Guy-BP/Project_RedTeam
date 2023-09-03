pipeline {
    agent any
    environment {
        def DOCKERHUB_CREDENTIALS = params.get('dockerpss')
        def AWS_SECRET_KEY = "${aws}"
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
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
        stage('Login') {
            steps {
                sh 'docker login -u guy66bp -p $DOCKERHUB_CREDENTIALS'
            }
        }
        stage('Push') {
            steps {
                sh 'docker push guy66bp/appserver'
                sh 'docker push guy66bp/appfront'     
                sh 'docker rmi -f guy66bp/appserver'
                sh 'docker rmi -f guy66bp/appfront'
            }
        }
        stage('TF init&plan') {
            steps{
                sh 'terraform init'
                sh 'terraform plan -var "secret_key = $(AWS_SECRET_KEY)"'
            }
        }

            }
        }
        stage('Remove images') {
            steps {
                sh 'docker kill $(docker ps -q)'
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
    }
}
}