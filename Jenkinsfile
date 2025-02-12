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
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                        docker tag my-static-site:latest $ECR_REPO:latest
                        docker push $ECR_REPO:latest
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
                          --targets Key=tag:aws:autoscaling:groupName,Values=$ASG_NAME \
                          --parameters 'commands=["aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO", "docker pull $ECR_REPO:latest", "docker stop my-static-container || true", "docker rm my-static-container || true", "docker run -d -p 80:3000 --restart always --name my-static-container $ECR_REPO:latest"]' \
                          --timeout-seconds 600 \
                          --region $AWS_REGION
                    '''
                }
            }
        }
    }
}

