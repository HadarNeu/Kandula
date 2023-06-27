	pipeline {

	    agent {
	        node {
	            label 'aws-linux-ec2-plugin'
	        }
	    }

	    environment {
        	DB_HOST = ""
    	}

	    stages {
	    
		stage('Get RDS Endpoint') {
            steps {
                withAWS(credentials:'aws-creds-hadarnoy') {
				// withAWS(region: '${AWS_DEFAULT_REGION}', credentials: 'my-aws-credentials') {
                    script {
                        env.DB_HOST = sh(
                            script: "aws rds describe-db-instances --db-instance-identifier ${DB_INSTANCE_IDENTIFIER} --output text",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('Print RDS Endpoint') {
            steps {
                echo "RDS Endpoint: $env.DB_HOST"
                // Use the RDS_ENDPOINT variable in subsequent steps
            }
        }
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
	         
	        // Building Docker images
	        stage('Building image') {
	            steps{
					sh 'cd Kandula-App'
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
						sh "kubectl describe svc kandula-app-lb-service | grep 'LoadBalancer'"
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