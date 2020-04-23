pipeline{
    agent any
    stages {
        stage('build') {
            steps{
                sh './mvnw package -Dcheckstyle.skip'
            }
        }
        stage('release') {
            steps{
                rtUpload (
                serverId: 'artifactory-1',
                spec: '''{
                    "files": [
                        {
                        "pattern": "target/*.jar",
                        "target": "maven-artifacts/"
                        }
                    ]
                    }'''
                )
                rtPublishBuildInfo (
                    serverId: 'artifactory-1'
                )
            }
        }

        stage('deploy'){
            steps{
                //deploy to petclinic-vm
                withCredentials([usernamePassword(credentialsId:'79590f1b-45a9-4ed6-ad8f-ea87d033efe3', passwordVariable: 'PASSWORD', usernameVariable: 'SSH_CRED')]) {
                    sh 'sshpass -p ${PASSWORD} scp -r docker-compose.yml Dockerfile  wait-for-it.sh target/ ${SSH_CRED}:~/spring-petclinic/'
                    sh 'sshpass -p ${PASSWORD} ssh ${SSH_CRED} "docker build ~/spring-petclinic/ -t petclinic:v1"'
                    sh 'sshpass -p ${PASSWORD} ssh ${SSH_CRED} "docker tag petclinic:v1 dockerregistrycicd.azurecr.io/petclinic:v1"'
                    sh 'sshpass -p ${PASSWORD} ssh ${SSH_CRED} "docker push dockerregistrycicd.azurecr.io/petclinic:v1"'
                    sh 'sshpass -p ${PASSWORD} ssh ${SSH_CRED} "docker rmi dockerregistrycicd.azurecr.io/petclinic:v1"'
                    sh 'sshpass -p ${PASSWORD} ssh ${SSH_CRED} "docker-compose -f spring-petclinic/docker-compose.yml up --force-recreate --build -d"'
		    sh 'sshpass -p ${PASSWORD} ssh ${SSH_CRED} "docker image prune -f"'

                }
            }
        }
    }
}
