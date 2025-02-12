pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth'
        ASG_NAME = 'my-auto-scaling-group'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/nitron18/cicd-test.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-static-site .'
            }
        }

        stage('Push to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth
                        docker tag my-static-site:latest 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest
                        docker push 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest
                    '''
                }
            }
        }

        stage('Refresh ASG Instances via SSM') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                        aws ssm send-command \
                          --document-name "AWS-RunShellScript" \
                          --targets Key=tag:aws:autoscaling:groupName,Values=my-auto-scaling-group \
                          --parameters 'commands=[
                              "sh -c \\\"aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth\\\"",
                              "docker pull 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest",
                              "docker stop my-static-container || true",
                              "docker rm my-static-container || true",
                              "docker run -d -p 80:3000 --restart always --name my-static-container 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest"
                          ]' \
                          --timeout-seconds 600 \
                          --region us-east-1
                    '''
                }
            }
        }
    }
}

