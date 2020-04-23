def imageVersion="1.0.${BUILD_NUMBER}"
def targetMail = "jenkinsautomationuser@gmail.com"

def emailBuildStatus(targetMail) {
    emailext body: "please look into the build: ${BUILD_URL}", subject: "${currentBuild.result}: ${BUILD_TAG}", to: "${targetMail}"
}

pipeline{
    agent {label 'slave'}
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
        stage('Containerization:push to acr'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'acr_creds',passwordVariable: 'password', usernameVariable: 'username')]) {
                            sh'''
                                docker build -t pet-clinic:1.0.${BUILD_NUMBER} .
                                docker ps -qa --filter name=pet-clinic_container|grep -q . && (docker stop pet-clinic_container && docker rm pet-clinic_container) ||echo pet-clinic_container doesn\\'t exists
                                docker login myfirstprivateregistry.azurecr.io -u ${username} -p ${password}
                                docker tag pet-clinic:1.0.${BUILD_NUMBER} myfirstprivateregistry.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}
                                docker push myfirstprivateregistry.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}
                            '''
                }
            }
        }
        stage('Deploy using aks'){
            when {
                branch 'master'
            }
            steps{
                withCredentials([azureServicePrincipal('sp_for_FreeTrial-Nagaraju_sub')]) {
                  sh '''
                    az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                    az account set -s $AZURE_SUBSCRIPTION_ID
                  '''
                  sh 'az aks get-credentials --resource-group Demo-4 --name pet-clinic'
                  sh 'kubectl get nodes'
                  sh "kubectl set image deployment/petclinic-app webapp=myfirstprivateregistry.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}"
                  sh "kubectl get services petclinic-app"
                }
                sh 'az logout'
            }
        }
        stage('verify') {
            steps {
                script {
                    def pet_service=sh(returnStdout: true, script: "kubectl get service|grep petclinic-ap").trim()
                    def pub_ip = pet_service.split()[3]
                    def http_status_code = sh(returnStdout: true, script: "curl -I http://${pub_ip}:80|head -n 1|cut -d ' ' -f2").trim()
                    if (http_status_code == "200") {
                        echo "The application http://${pub_ip}:80 is successfully deployed.\n http status code is ${http_status_code}"
                    }
                    else {
                        echo "The application http://${pub_ip}:80 status code is ${http_status_code}. Please look into it."
                    }
                }
            }
        }
    }
    post {
        always {
			emailBuildStatus(targetMail)
        }
    }
}
