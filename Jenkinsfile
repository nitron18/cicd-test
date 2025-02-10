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
                withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                        docker tag my-static-site:latest $ECR_REPO:latest
                        docker push $ECR_REPO:latest
                    '''
                }
            }
        }

        stage('Update Auto Scaling Group') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
                    sh '''
                        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $ASG_NAME \
                            --launch-template LaunchTemplateName=my-launch-template,Version='$Latest'
                    '''
                }
            }
        }
    }
}

