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
        stage('Containerization'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'password', usernameVariable: 'username')]) {
                sh "docker login -u ${username} -p ${password}"
                sh "docker build -t sachinshrma/petclinic:${imageVersion} ."
                sh 'docker build -t sachinshrma/petclinic:latest .'
                sh "docker push sachinshrma/petclinic:${imageVersion}"
                sh 'docker push sachinshrma/petclinic:latest'
                }
            }
        }
        stage('Deploy'){
            steps{
                dir("terraform"){
                withCredentials([azureServicePrincipal('sp_for_FreeTrial-Nagaraju_sub')]) {
                  sh '''
                    terraform init -input=false
                    terraform apply -var="prefix=prod" -var="subscription_id=${AZURE_SUBSCRIPTION_ID}" -var="client_id=${AZURE_CLIENT_ID}" -var="client_secret=${AZURE_CLIENT_SECRET}" -var="tenant_id=${AZURE_TENANT_ID}" -input=false -auto-approve
                    echo "$(terraform output kube_config)" > ./azurek8s
                    export KUBECONFIG=./azurek8s PETCLINIC_IMAGE=sachinshrma/petclinic:${imageVersion}
                    kubectl get nodes
                    kubectl apply -f petclinic-mysql.yml
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
