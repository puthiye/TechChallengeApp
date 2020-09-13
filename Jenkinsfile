#!/usr/bin/env groovy

pipeline { 
agent any

        stages {

         stage("install docker/git - rhel") {

            steps{

                script{
                          sh 'export ANSIBLE_HOST_KEY_CHECKING=False'

                          //credentials -> secret file 
                          withCredentials([file(credentialsId: 'SSH-PRIVATE-KEY', variable: 'mySecretFile')]) {
    
                                           sh '''
                                              echo "Copy the content to /tmp location `cat $mySecretFile > /tmp/key.file`"
                                              chmod 700 /tmp/key.file
                                              '''
                          }
                    
                         sh 'ansible-playbook -i ${DEPLOY_ENDPOINT}, ./ansible/setup.yml --extra-vars="ansible_ssh_private_key_file=/tmp/key.file ansible_user=ec2-user" '
                          
                         //delete the ssh key after use
                         dir("/tmp/key.file") {
                              deleteDir()
                         }      

                      }                   

                }
            }

        }


      stage("docker build image") {
      steps {
        script {

          //credentials -> username + password
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

  } //end of stages
} //end of pipeline

