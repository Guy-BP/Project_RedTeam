pipeline {
    agent any
    stages {
        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Log in to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_USER', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKER_PSWRD')]) {
                        sh "docker login -u $DOCKERHUB_USERNAME -p $DOCKER_PSWRD"
                        
                        // Build and push Docker images
                        sh 'docker build -t guy66bp/appserver ./server'
                        sh 'docker push guy66bp/appserver'
                        sh 'docker build -t guy66bp/appfront ./frontend'
                        sh 'docker push guy66bp/appfront'
                    }
                }
            }
        }
        
        stage('Deploy Containers') {
            steps {
                // Deploy containers here
                sh 'docker run -d -p 3001:3001 guy66bp/appserver'
                sh 'sleep 5'
                sh 'docker run -d -p 3000:3000 guy66bp/appfront'
                sh 'sleep 5'
            }
        }

        stage('Run Tests') {
            steps {
                // Run your tests here
                sh 'python3 -m pytest --junitxml=testresault.xml test/test.py'
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                // Use AWS CLI to configure AWS credentials
                withCredentials([string(credentialsId: 'AWS_ACCESS', variable: 'AWS_ACCESS_KEY_ID'),
                                 string(credentialsId: 'AWS_SHEKET', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
                    sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
                }
                
                // Initialize and plan Terraform
                sh 'terraform init'
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                // Apply Terraform changes (only if the previous stages were successful)
                sh 'terraform apply -auto-approve'
            }
        }
    }
    post {
        always {
            // Log out of Docker Hub
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


