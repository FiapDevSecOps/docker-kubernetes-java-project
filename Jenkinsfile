pipeline {
    agent any

    environment {
        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no' // Skip host key checking
        CONTAINER1 = 'productcatalogue'
        CONTAINER2 = 'shopfront'
        CONTAINER3 = 'stockmanager'
        USER = 'rosthan'
        TAG = 'v1'
        DOCKERFILE_PATH = 'Dockerfile.master'

    }

    stages {
        stage('Checkout') {
            steps {
                git BRANCH_NAME: 'main', url: 'https://github.com/FiapDevSecOps/docker-kubernetes-java-project.git'
            }
        }

        stage('Productcatalogue - Build e Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd productcatalogue
                        mvn clean install -DskipTests
                        docker login -u $HUB_USER -p $HUB_TOKEN 
                        docker build -t ${USER}/${CONTAINER1}:${BRANCH_NAME}-${TAG} .
                        docker push ${USER}/${CONTAINER1}:${TAG}
                    '''
                }
                
                // Add your build and test steps here
            }
        }

        stage('shopfront - Build e Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd shopfront
                        mvn clean install -DskipTests
                        docker login -u $HUB_USER -p $HUB_TOKEN 
                        docker build -t ${USER}/${CONTAINER2}:${BRANCH_NAME}-${TAG} . 
                        docker push ${USER}/${CONTAINER2}:${TAG}
                    '''
                }
                
                // Add your build and test steps here
            }
        }

        stage('stockmanager - Build e Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd stockmanager
                        BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)  
                        mvn clean install -DskipTests
                        docker login -u $HUB_USER -p $HUB_TOKEN 
                        docker build -t ${USER}/${CONTAINER3}:${BRANCH_NAME}-${TAG} .
                        docker push ${USER}/${CONTAINER3}:${BRANCH_NAME}-${TAG}
                    '''
                }
                
                // Add your build and test steps here
            }
        }
    }
}