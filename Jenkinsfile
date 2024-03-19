pipeline {

    agent { label 'docker' }

    environment {

        // ID da chave de acesso da AWS
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        // Chave secreta de acesso da AWS
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        // Token de sessão da AWS
        AWS_SESSION_TOKEN = credentials('AWS_SESSION_TOKEN')
    }

    stages {

        stage('Checkout') {

            steps {

                git branch: 'main', url: 'https://github.com/FiapDevSecOps/docker-kubernetes-java-project.git'
            }

        }

        stage('Terraform init') {

            steps {

                sh '''
                   export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                   export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                   export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                   terraform init -upgrade  -no-color
                   '''

            }

        }

        stage('Terraform apply') {

            steps {

                sh '''
                   export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                   export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                   export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
                   terraform apply -auto-approve  -no-color
                   '''
            }
        }
    }
}