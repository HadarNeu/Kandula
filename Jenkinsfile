	pipeline {
// ***********
        // ****** TODO install dependencies on agents and change the AMI
        // 
// ***********


	    // ***TODO insert the correct label
	    agent {
	        node {
	            label 'aws-ec2-amazon-linux-agent'
	        }
	    }
	    
	    
	    environment {
	    AWS_ACCOUNT_ID      = "854639092412"
	    AWS_DEFAULT_REGION  = "us-west-2"
	    IMAGE_REPO_NAME     = "hadarneu"
	    IMAGE_TAG           = "latest"
	    REPO_URL            = "https://github.com/HadarNeu/Kandula.git"
	    PYTHON_APP_IMAGE    = "python:3.9-slim"
	    }
	    
	    stages {
	        
            // ****** TODO credentials ID for github token!
	        stage('Cloning Git') {
	            steps {
	                git url: "${REPO_URL}", branch: 'main',
	                 credentialsId: 'Github_token'
	            }
	        } 
	        
	        // Restarting docker     
	        stage ('Restart docker') {
	             steps {
	                 sh 'sudo service docker restart'
	          }
	        }
	         
              // ****** TODO understand how to configure this to build my app correctly!!!
	        // Building Docker images
	        stage('Building image') {
	            steps{
	                script {
	                    dockerImage = docker.build "${IMAGE_REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
	                }
	            }
	        }
	        
	         // Uploading Docker images into DockerHub
	        stage('Pushing to DockerHub') {
	            steps{
	                script {
	                    // sh "docker tag ${IMAGE_REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
	                    sh "docker push ${IMAGE_REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
	                }
	            }
	        }

            // ****TODO find a way to make agents clean itself up at the end

	        // stage ('Delete the docker images') {
	        //      steps {
	        //          sh "docker rmi -f ${PYTHON_APP_IMAGE}"
	        //          sh "docker rmi -f ${REPOSITORY_URI}"
	        //          sh "docker rmi -f ${IMAGE_REPO_NAME}:${IMAGE_TAG}"
	        //   }
	        // }

            // stage ('Delete the cloned repo') {
	        //      steps {
	        //          sh "rm -rf ${REPO_DIR}"
	        //   }
	        // }
	                
	//         stage ('Delete the folder and the files that has copied from the cloned repo using Dockerfile') {
	//              steps {
	//                  sh "rm -rf /home/ec2-user/jenkins-agent/jenkins-agent/workspace/kandula"
	//                  sh "rm -rf /home/ec2-user/jenkins-agent/jenkins-agent/workspace/kandula@tmp"
	//           }
	//         }
	        

	        // ********* TODO Insert credentials ID
	        stage ("Login to EKS") {
	            steps {
	                withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'eks.cred', namespace: '', serverUrl: '') {
	                }
	              }
	            }
	        
	        stage ("Deploy to EKS") {
	            steps {
	                sh "kubectl apply -f deployment-kandula.yaml"
                    sh "kubectl apply -f lb-service-kandula.yaml"
	                }
	              }
	        
            //  TODO Slack notification 
	        // stage('Slack notification') {
	        //     steps {
	        //         script {
	        //             def status = currentBuild.currentResult // Get the result of the current build
	        //             def message = status == 'SUCCESS' ? "Build #${env.BUILD_NUMBER} succeeded!" : "Build #${env.BUILD_NUMBER} failed!"
	        //             try {
	        //                 slackSend channel: 'jenkins-notifications', color: status == 'SUCCESS' ? '#36a64f' : '#ff0000', message: message, tokenCredentialId: 'slack.integration'
	        //             } catch (Exception e) {
	        //                 echo "Slack notification failed with error: ${e.getMessage()}"
	        //             }
	        //         }
	        //     }
	        // }
	        
	  }
}   