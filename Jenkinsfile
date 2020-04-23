def image_version="v${BUILD_NUMBER}"
pipeline{
    agent {label 'slave_agent'}
    stages {
        
        stage('build') {
            steps{
                sh './mvnw package -Dcheckstyle.skip'
            }
        }

        stage('upload image to ACR'){
            steps{
                withCredentials([usernamePassword(credentialsId:'acr_creds', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                    sh 'docker login myfirstprivateregistry.azurecr.io -u ${USERNAME} -p ${PASSWORD} '
                }
                sh "chmod 766 wait-for-it.sh"
                sh "docker build . -t petclinic:${image_version}"
                sh "docker tag petclinic:${image_version} myfirstprivateregistry.azurecr.io/petclinic:${image_version}"
                sh "docker push myfirstprivateregistry.azurecr.io/petclinic:${image_version}"
                sh "docker rmi myfirstprivateregistry.azurecr.io/petclinic:${image_version}"
            }
        }

        stage('deploy to webapp'){
            steps{
                sh "sed -i \"s|{image_name}|myfirstprivateregistry.azurecr.io/petclinic:${image_version}|g\" docker-compose-webapp.yml"
                withCredentials([azureServicePrincipal('d6cfe462-e4d5-4ddd-86e2-f70ec74c3f01	')]){
                    sh "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID"
                }
                sh "az webapp config container set --resource-group cicd-rg --name petclinic --multicontainer-config-type compose --multicontainer-config-file docker-compose-webapp.yml"
                sh 'az logout'
            }
        }
    }
}