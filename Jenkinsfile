pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = params.get('dockerpss')
        AWS_SECRET_KEY = params.get('awsecret')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                // Build Docker images for the server and frontend
                sh 'docker build -t guy66bp/appserver ./server'
                sh 'docker build -t guy66bp/appfront ./frontend'
            }
        }
        stage('Deploy Containers') {
            steps {
                // Deploy Docker containers for the server and frontend
                sh 'docker run -d -p 3001:3001 guy66bp/appserver'
                sh 'sleep 2' // Give the container some time to start up
                sh 'docker run -d -p 3000:3000 guy66bp/appfront'
                sh 'sleep 2' // Give the container some time to start up
            }
        }
        stage('Login') {
            steps {
                // Log in to Docker Hub
                sh "docker login -u guy66bp -p ${DOCKERHUB_CREDENTIALS}"
            }
        }
        stage('Push') {
            steps {
                // Push Docker images to Docker Hub
                sh 'docker push guy66bp/appserver'
                sh 'docker push guy66bp/appfront'     
                sh 'docker rmi -f guy66bp/appserver'
                sh 'docker rmi -f guy66bp/appfront'
            }
        }
        stage('TF init&plan') {
            steps {
                // Initialize Terraform and create an execution plan
                sh 'terraform init'
                sh "terraform plan -var=\'AWS_SECRET_KEY=${AWS_SECRET_KEY}\'"
            }
        }
        stage('Remove containers') {
            steps {
                // Remove running Docker containers
                sh 'docker rm -f $(docker ps -q)'
            }
        }
        stage('TF Approval') {
            steps {
                // Apply Terraform changes (infrastructure deployment)
                sh "terraform apply -var=\'AWS_SECRET_KEY=${AWS_SECRET_KEY}\' -auto-approve"
            }
        }
    }
    post {
        always {
            // Log out from Docker Hub
            sh 'docker logout'
        }
    }
}
