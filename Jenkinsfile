	pipeline {

	    agent {
	        node {
	            label 'aws-linux-ec2-plugin'
	        }
	    }
	    
	    
	    environment {
	    AWS_ACCOUNT_ID      = "854639092412"
	    AWS_DEFAULT_REGION  = "us-west-2"
	    IMAGE_REPO_NAME     = "hadarneu"
	    IMAGE_TAG           = "latest"
		IMAGE_NAME          = "kandula"
	    REPO_URL            = "https://github.com/HadarNeu/Kandula.git"
	    PYTHON_APP_IMAGE    = "python:3.9-slim"
		CLUSTER_NAME        = "opsschool-eks-hadar-IPw65Blz"
	    }
	    
	    stages {
	        

        // ****** TODO credentials ID for github token! V
        stage('Cloning Git') {
            steps {
                git url: "${REPO_URL}", branch: 'local-ubuntu',
                 credentialsId: 'git-token-hadarneu'
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
	                withDockerRegistry(credentialsId: 'docker-hub-creds-hadarneu', url: '') {
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
	        

	        stage ("Login to EKS") {
	            steps {

					withAWS(credentials:'aws-creds-hadarnoy') {
    					sh "aws eks --region=${AWS_DEFAULT_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
					}
					
	              }
	            }
	        
	        stage ("Deploy to EKS") {
	            steps {
					withAWS(credentials:'aws-creds-hadarnoy') {
						sh "kubectl apply -f deployment-kandula.yaml"
						sh "kubectl apply -f lb-service-kandula.yaml"
					}

	                }
	              }
	        stage ("Display app link") {
                steps {
					withAWS(credentials:'aws-creds-hadarnoy') {
						sh "kubectl describe svc kandula-app-lb-service | grep 'LoadBalancer Ingress:'"
					}
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