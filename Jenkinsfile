def imageVersion="1.0.${BUILD_NUMBER}"
pipeline{
    agent {label 'slave_agent'}
    stages{    
        stage('Build'){
            steps{
                sh './mvnw package'
            }
        }
        stage('Code analysis'){
            steps{
                sh './mvnw verify sonar:sonar'
            }
        }
        
        stage('Containerization:push to acr') {
                steps {
                    withCredentials([usernamePassword(credentialsId: 'acr-pratik-id',passwordVariable: 'password', usernameVariable: 'username')]) {
                            sh'''
                                docker build -t pet-clinic:1.0.${BUILD_NUMBER} .
                                docker ps -qa --filter name=pet-clinic_container|grep -q . && (docker stop pet-clinic_container && docker rm pet-clinic_container) ||echo pet-clinic_container doesn\\'t exists
                                docker login petclinicacr17.azurecr.io -u ${username} -p ${password}
                                docker tag pet-clinic:1.0.${BUILD_NUMBER} petclinicacr17.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}
                                docker push petclinicacr17.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}
                            '''
                }
            }
        }
        stage('Deploy'){
            steps{
                withCredentials([azureServicePrincipal('sp_for_FreeTrial-Nagaraju_sub')]) {
                  sh '''
                    az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                    az account set -s $AZURE_SUBSCRIPTION_ID
                  '''
                  sh 'az aks get-credentials --resource-group Demo-4 --name pet-clinic'
                  sh 'kubectl get nodes'
                  sh "kubectl set image deployment/petclinic-app webapp=petclinicacr17.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}"
                }
                sh 'az logout'
               
            }
        }
    }
    post {
        always {
			emailext (
                to: "",
                subject: '${DEFAULT_SUBJECT}',
                body: '${DEFAULT_CONTENT}',
            )
        }
    }
}
