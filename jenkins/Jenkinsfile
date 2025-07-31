pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        ANSIBLE_HOST_KEY_CHECKING = 'False'
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
                sh 'chmod +x terraform/inventory-gen.sh'
                sh './terraform/inventory-gen.sh'
                sh 'cat terraform/ansible/inventory.ini'
            }
        }

        stage('Checkout Apache NiFi 1.26.0') {
            steps {
                sh '''
                    rm -rf nifi
                    git clone https://github.com/apache/nifi.git
                    cd nifi
                    git checkout rel/nifi-1.26.0
                '''
            }
        }

        stage('Build NiFi with Maven') {
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
                        mkdir -p ansible
                        cp terraform/ansible/inventory.ini ansible/inventory.ini

                        sed -i "s|ansible_ssh_private_key_file=.*|ansible_ssh_private_key_file=$NIFI_KEY_FILE|" ansible/inventory.ini

                        ansible-playbook -i ansible/inventory.ini ansible/install-nifi.yml
                    '''
                }
            }
        }

        stage('Show NiFi URL') {
            steps {
                script {
                    def ip = sh(script: "terraform -chdir=terraform output -raw instance_public_ip", returnStdout: true).trim()
                    echo "\u2705 NiFi is now available at: http://${ip}:8443/nifi"
                }
            }
        }
    }
}
