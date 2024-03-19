pipeline {
    agent { label 'docker' }

    environment {
        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no' // Skip host key checking
        APP = 'productcatalogue'
        USER = 'rosthan'
        TAG = 'v1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/FiapDevSecOps/docker-kubernetes-java-project.git'
            }
        }

        stage('Meaven Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd ${APP}
                        mvn clean install -DskipTests
                    '''
                }
            }
        }

        stage('Secure Scan Test') {
            steps {
                grypeScan scanDest: 'dir:/tmp/grpc', repName: 'myScanResult.txt', autoInstall:true
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd ${APP}
                        docker login -u $HUB_USER -p $HUB_TOKEN 
                        docker build -t ${USER}/${APP}:${TAG} -t ${USER}/${APP}:latest .
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd ${APP}
                        docker login -u $HUB_USER -p $HUB_TOKEN 
                        docker push ${USER}/${APP}:latest 
                    '''
                }
            }
        }

      // Etapa de workflow do Terraform
        stage('Terraform Workflow') {
            parallel {
                // Etapa de inicialização do Terraform
                stage('Terraform Init') {
                    
                    steps {
                        dir("terraform")  {
                            sh '''
                                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                                export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                                terraform init -upgrade
                        '''
                        }

                        
                    }
                }
                // Etapa de plano do Terraform
                stage('Terraform Plan') {
                    steps {
                        dir("terraform")  {
                            sh '''
                                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                                export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                                terraform init -upgrade
                        '''
                        }
                    }
                }
                // Etapa de aplicação do Terraform
                stage('Terraform Apply') {
                    steps {
                        dir("terraform")  {
                            sh '''
                                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                                export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                                terraform init -upgrade
                        '''
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            recordIssues(
              tools: [grype()],
              aggregatingResults: true,
              failedNewAll: 1, //fail if >=1 new issues
              failedTotalHigh: 20, //fail if >=20 HIGHs
              failedTotalAll : 100, //fail if >=100 issues in total
              filters: [
                excludeType('CVE-2023-2976'),
                excludeType('CVE-2012-17488'),
              ],
              //failOnError: true
            )
        }

        success {
            echo 'This will run only if successful'
        }

        failure {
            echo 'This will run only if failed'
        }

        unstable {
            echo 'This will run only if the run was marked as unstable'
        }

        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
