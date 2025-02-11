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

        stage('Update Auto Scaling Group') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                        aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-asg \
                            --launch-template LaunchTemplateName=my-template,Version='$Latest'
                    '''
                }
            }
        }
    }
}

