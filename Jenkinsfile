pipeline {
    // Define que o pipeline será executado em um agente com a label 'docker'
    agent { label 'docker' }

    // Define as variáveis de ambiente que serão utilizadas no pipeline
    environment {
        // Configuração para pular a verificação do host SSH
        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no'
        // Nome da aplicação
        APP = 'productcatalogue'
        // Nome do usuário
        USER = 'rosthan'
        // Tag da imagem Docker
        TAG = 'v1'
        // ID da chave de acesso da AWS
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        // Chave secreta de acesso da AWS
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        // Token de sessão da AWS
        AWS_SESSION_TOKEN = credentials('AWS_SESSION_TOKEN')
    }

    // Definição das etapas do pipeline
    stages {
        // Etapa de checkout do código-fonte
        stage('Checkout') {
            steps {
                git branch: 'full_pipeline', url: 'https://github.com/FiapDevSecOps/docker-kubernetes-java-project.git'
            }
        }

        // Etapa de build com Maven
        stage('Maven Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd ${APP}
                        mvn clean install -DskipTests
                    '''
                }
            }
        }

        // Etapa de teste de segurança
        stage('Secure Scan Test') {
            steps {
                grypeScan scanDest: 'dir:/tmp/grpc', repName: 'myScanResult.txt', autoInstall:true
            }
        }

        // Etapa de build da aplicação
        stage('Build App') {
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

        // Etapa de push da imagem Docker
        stage('Push App') {
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
                        sh 'export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"'
                        sh 'export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"'
                        sh 'export AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"'
                        sh 'cd terraform && terraform init -upgrade'
                    }
                }
                // Etapa de plano do Terraform
                stage('Terraform Plan') {
                    steps {
                        sh 'cd terraform && terraform init -upgrade && terraform plan -out=plan.file'
                    }
                }
                // Etapa de aplicação do Terraform
                stage('Terraform Apply') {
                    steps {
                        sh 'cd terraform && terraform init -upgrade && terraform apply plan.file -auto-approve'
                    }
                }
            }
        }
    }

    // Define as ações a serem executadas após a execução do pipeline
    post {
        // Executado sempre, independentemente do resultado
        always {
            recordIssues(
              tools: [grype()],
              aggregatingResults: true,
              failedNewAll: 1, //falha se houver >=1 novos problemas
              failedTotalHigh: 20, //falha se houver >=20 HIGHs
              failedTotalAll : 100, //falha se houver >=100 problemas no total
              filters: [
                excludeType('CVE-2023-2976'),
                excludeType('CVE-2012-17488'),
              ],
              //failOnError: true
            )
        }

        // Ação a ser executada em caso de sucesso
        success { 
           bash ./deploy.sh
        }

        // Ação a ser executada em caso de falha
        failure { 
            echo 'This will run only if failed'
        }

        // Ação a ser executada em caso de instabilidade
        unstable { 
            echo 'This will run only if the run was marked as unstable'
        }

        // Ação a ser executada se o estado do Pipeline mudar
        changed { 
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
