pipeline {
    agent any
	environment {
        DOCKERHUB_USERNAME = credentials('DOCKER_USER').username
        DOCKERHUB_PASSWORD = credentials('DOCKER_PSWRD').password
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS').accessKeyId
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SHEKET').secretKey
	}
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
//        stage('Run Tests') {
//            steps {
//                sh 'python3 -m pytest --junitxml==testresault.xml test/test.py'
//            }
//       }
	    stage('Login') {
	    	steps {
		    	sh 'echo $DOCKER_PSWRD | docker login -u $DOCKER_USER --password-stdin'
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
        script {
            withCredentials([string(credentialsId: 'AWS_ACCESS', variable: 'AWS_ACCESS_KEY_ID'),
                            string(credentialsId: 'AWS_SHEKET', variable: 'AWS_SECRET_ACCESS_KEY')]) {
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
//         success {
//             echo "Tests passed, pipeline succeeded!"
//             cleanUpContainers()
//         }
//         failure {
//             echo "Tests failed, pipeline failed!"
//             cleanUpContainers()
//         }
//     }
    }
}