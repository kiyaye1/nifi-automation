pipeline {
    agent any

    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    tools {
        jdk 'java'
        maven 'mvn'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Provision EC2 with Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                sh './terraform/inventory-gen.sh'
                sh 'cat ansible/inventory.ini'
            }
        }

        stage('Checkout NiFi 1.26.0') {
            steps {
                sh '''
                    git clone https://github.com/apache/nifi.git
                    cd nifi
                    git checkout rel/nifi-1.26.0
                '''
            }
        }

        stage('Build with Maven') {
            steps {
                dir('nifi/nifi-assembly') {
                    sh 'mvn clean install -U -DskipTests'
                }
            }
        }

        stage('Install NiFi with Ansible') {
            steps {
                withCredentials([file(credentialsId: 'nifi-key', variable: 'NIFI_KEY_FILE')]) {
                    sh '''
                        sed "s|ansible_ssh_private_key_file=.*|ansible_ssh_private_key_file=$NIFI_KEY_FILE|" \
                            ansible/inventory.ini > ansible/inventory_final.ini

                        ansible-playbook -i ansible/inventory_final.ini ansible/install-nifi.yml
                    '''
                }
            }
        }

        stage('Show NiFi URL') {
            steps {
                script {
                    def ip = sh(script: "terraform -chdir=terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "NiFi is now available at: http://${ip}:8443/nifi"
                }
            }
        }
    }
}
