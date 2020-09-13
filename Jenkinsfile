#!/usr/bin/env groovy

pipeline { 
agent any

        stages {

         stage("install docker/git - rhel") {

            steps{

                script{
                          sh 'export ANSIBLE_HOST_KEY_CHECKING=False'
                          sh 'sudo ansible-playbook -i ${DEPLOY_ENDPOINT}, setup.yml --extra-vars="ansible_ssh_private_key_file=/home/ucp/proj/key0.pem ansible_user=ec2-user" '
                      
                        }                   

                }
            }

        }


      stage("docker build image") {
      steps {
        script {

          withCredentials([
            usernamePassword(credentialsId: 'GIT_CREDS',
              usernameVariable: 'username',
              passwordVariable: 'password')
          ]) {
            
              sshagent(credentials: ['dev-ssh']) {
               sh "ssh -o StrictHostKeyChecking=no ec2-user@${DEPLOY_ENDPOINT} rm -rf TechChallengeApp"
               sh "ssh -o StrictHostKeyChecking=no ec2-user@${DEPLOY_ENDPOINT} git clone https://github.com/puthiye/TechChallengeApp.git" 
               sh "ssh -o StrictHostKeyChecking=no ec2-user@${DEPLOY_ENDPOINT} sudo docker build /home/ec2-user/TechChallengeApp/ -t techchallengeapp"
            }
  
            
          } 
        }
      }
    }


     stage("docker run containers") {
      steps {
        script {
    
                   sshagent(credentials: ['dev-ssh']) {
               
                    sh "ssh -o StrictHostKeyChecking=no ec2-user@${DEPLOY_ENDPOINT} sudo docker run -d -P --publish 127.0.0.1:5432:5432 -e POSTGRES_PASSWORD=changeme --name db postgres"    

                    sh "ssh -o StrictHostKeyChecking=no ec2-user@${DEPLOY_ENDPOINT} sudo docker run --net container:db techchallengeapp updatedb"

                    sh "ssh -o StrictHostKeyChecking=no ec2-user@${DEPLOY_ENDPOINT} sudo docker run -p 3000:3000 techchallengeapp serve"

                   }


       }
      }
    }


}

