pipeline{
    agent any
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
                    withCredentials([usernamePassword(credentialsId: 'acr_creds',passwordVariable: 'password', usernameVariable: 'username')]) {
                            sh'''
                                docker build -t pet-clinic:1.0.${BUILD_NUMBER} .
                                docker ps -qa --filter name=pet-clinic_container|grep -q . && (docker stop pet-clinic_container && docker rm pet-clinic_container) ||echo pet-clinic_container doesn\\'t exists
                                docker login rddevops.azurecr.io -u ${username} -p ${password}
                                docker tag pet-clinic:1.0.${BUILD_NUMBER} rddevops.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}
                                docker push rddevops.azurecr.io/pet-clinic:1.0.${BUILD_NUMBER}
                            '''
                }
            }
        }
        stage('Deploy'){
            steps{
                dir("TFAKS"){
                withCredentials([azureServicePrincipal('sp_for_FreeTrial-Nagaraju_sub'),usernamePassword(credentialsId: 'acr_creds', passwordVariable: 'password', usernameVariable: 'username')]) {
                  sh'''
                        #az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                        #az group create --name "tstate" --location eastus
                        #az storage account create --resource-group "tstate" --name "tstateaksdemo" --sku Standard_LRS --encryption-services blob
                        #ACCOUNT_KEY=$(az storage account keys list --resource-group tstate --account-name tstateaksdemo --query [0].value -o tsv)
                        #az storage container create --name tstate --account-name tstateaksdemo --account-key $ACCOUNT_KEY
                 
                    terraform init -input=false
                    terraform apply -var="prefix=prod" -var="subscription_id=${AZURE_SUBSCRIPTION_ID}" -var="client_id=${AZURE_CLIENT_ID}" -var="client_secret=${AZURE_CLIENT_SECRET}" -var="tenant_id=${AZURE_TENANT_ID}" -input=false -auto-approve
                    echo "$(terraform output kube_config)" > ./azurek8s
                    export KUBECONFIG=./azurek8s
                    kubectl get nodes
                    kubectl apply -f petclinic-mysql.yml
                    export PETCLINIC_IMAGE="rddevops.azurecr.io/petclinic:1.0.${BUILD_NUMBER}"
                    envsubst < petclinic-app.yml | kubectl apply -f -
                    kubectl describe services petclinic-app
                    kubectl describe pods --selector=app=petclinic-app
                  '''
                }
               
            }

            }
        }
    }
    post {
        always {
			emailext (
                to: "prateekghose765@gmail.com",
                subject: '${DEFAULT_SUBJECT}',
                body: '${DEFAULT_CONTENT}',
            )
        }
    }
}
