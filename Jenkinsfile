pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerpss')
        AWS_SECRET_KEY = credentials('awsecret')
    }
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
                sh 'echo $DOCKERHUB_CREDENTIALS | docker login -u guy66bp --password-stdin'
            }
        }
        stage('Push') {
            steps {
                sh 'docker push guy66bp/appserver'
                sh 'docker push guy66bp/appfront'
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
                sh 'echo "$AWS_SECRET_KEY" > aws_secret_key.txt'
                sh 'terraform init -backend-config="access_key=AKIAWGJSY6XBLG5SF6NF" -backend-config="secret_key=$(cat aws_secret_key.txt)"'
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
    }
}
