pipeline {
    agent { label 'docker' } // Define que o pipeline será executado em um agente com a label 'docker'

    environment { // Define as variáveis de ambiente que serão utilizadas no pipeline
        GIT_SSH_COMMAND = 'ssh -o StrictHostKeyChecking=no' // Configuração para pular a verificação do host SSH
        APP = 'productcatalogue' // Nome da aplicação
        USER = 'rosthan' // Nome do usuário
        TAG = 'v1' // Tag da imagem Docker
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID') // ID da chave de acesso da AWS
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY') // Chave secreta de acesso da AWS
        AWS_SESSION_TOKEN = credentials('AWS_SESSION_TOKEN') // Token de sessão da AWS
    }

    stages { // Definição das etapas do pipeline
        stage('Checkout') { // Etapa de checkout do código-fonte
            steps {
                git branch: 'full_pipeline', url: 'https://github.com/FiapDevSecOps/docker-kubernetes-java-project.git'
            }
        }

        stage('Maven Build') { // Etapa de build com Maven
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'HUB_USER', passwordVariable: 'HUB_TOKEN')]) {                      
                    sh '''
                        cd ${APP}
                        mvn clean install -DskipTests
                    '''
                }
            }
        }

        stage('Secure Scan Test') { // Etapa de teste de segurança
            steps {
                grypeScan scanDest: 'dir:/tmp/grpc', repName: 'myScanResult.txt', autoInstall:true
            }
        }

        stage('Build App') { // Etapa de build da aplicação
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

        stage('Push App') { // Etapa de push da imagem Docker
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

        stage('Terraform Workflow') { // Etapa de workflow do Terraform
            parallel { // Executa as etapas em paralelo
                stage('Terraform Init') { // Etapa de inicialização do Terraform
                    steps {
                        sh 'export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"'
                        sh 'export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"'
                        sh 'export AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"'
                        sh 'cd terraform && terraform init -upgrade'
                    }
                }
                stage('Terraform Plan') { // Etapa de plano do Terraform
                    steps {
                        sh 'cd terraform && terraform init -upgrade && terraform plan -out=plan.file'
                    }
                }
                stage('Terraform Apply') { // Etapa de aplicação do Terraform
                    steps {
                        sh 'cd terraform && terraform init -upgrade && terraform apply plan.file -auto-approve'
                    }
                }
            }
        }
    }

    post { // Define as ações a serem executadas após a execução do pipeline
        always { // Executado sempre, independentemente do resultado
            recordIssues( // Plugin para relatórios de problemas de segurança
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

        success { 
            
           bash ./deploy.sh
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