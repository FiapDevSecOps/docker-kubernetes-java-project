pipeline {
    agent any

    environment {
        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no' // Skip host key checking
        CONTAINER1 = 'productcatalogue'
        CONTAINER2 = 'shopfront'
        CONTAINER3 = 'stockmanager'
        USER = 'rosthan'
        TAG = 'v-${BUILD_NUMBER}'
        DOCKERFILE_PATH = 'Dockerfile.master'

    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/FiapDevSecOps/docker-kubernetes-java-project.git'
            }
        }

        stage('Productcatalogue - Build e Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd productcatalogue
                        mvn clean install -DskipTests
                        docker login -u $HUB_USER -p $HUB_TOKEN 
                        docker build -t ${USER}/${CONTAINER1}:${TAG} -t ${USER}/${CONTAINER1}:latest .
                        docker push ${USER}/${CONTAINER1}:latest 
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
                        docker build -t ${USER}/${CONTAINER2}:${TAG} -t ${USER}/${CONTAINER2}:latest . 
                        docker push ${USER}/${CONTAINER2}:latest 
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
                        mvn clean install -DskipTests
                        docker login -u $HUB_USER -p $HUB_TOKEN 
                        docker build -t ${USER}/${CONTAINER3}:${TAG} -t ${USER}/${CONTAINER3}:latest .
                        docker push ${USER}/${CONTAINER3}:latest 
                    '''
                }
                
                // Add your build and test steps here
            }
        }
    }
}