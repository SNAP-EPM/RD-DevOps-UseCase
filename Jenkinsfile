def imageVersion="1.0.${BUILD_NUMBER}"
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
        stage('Containerization'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'acr_creds', passwordVariable: 'password', usernameVariable: 'username')]) {
                sh "docker login ${username}.azurecr.io -u ${username} -p ${password}"
                sh "docker build -t ${username}.azurecr.io/petclinic:${imageVersion} ."
                sh "docker push ${username}.azurecr.io/petclinic:${imageVersion}"
                }
            }
        }
        stage('Deploy'){
            steps{
                dir("terraform"){
                withCredentials([azureServicePrincipal('sp_for_FreeTrial-Nagaraju_sub'),
                                usernamePassword(credentialsId: 'acr_creds', passwordVariable: 'password', usernameVariable: 'username')]) {
                  sh '''
                    terraform init -input=false
                    terraform apply -var="prefix=prod" -var="subscription_id=${AZURE_SUBSCRIPTION_ID}" -var="client_id=${AZURE_CLIENT_ID}" -var="client_secret=${AZURE_CLIENT_SECRET}" -var="tenant_id=${AZURE_TENANT_ID}" -input=false -auto-approve
                    echo "$(terraform output kube_config)" > ./azurek8s
                    export KUBECONFIG=./azurek8s
                    kubectl get nodes
                    kubectl create secret docker-registry acr-creds-secret --docker-server ${username}.azurecr.io --docker-email anyvalidmail@gmail.com --docker-username=${username} --docker-password ${password} --dry-run -o yml |kubectl apply -f -
                    kubectl apply -f petclinic-mysql.yml
                    export PETCLINIC_IMAGE="${username}.azurecr.io/petclinic:1.0.${BUILD_NUMBER}"
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
                to: "",
                subject: '${DEFAULT_SUBJECT}',
                body: '${DEFAULT_CONTENT}',
            )
        }
    }
}
