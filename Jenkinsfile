pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth'
        S3_BUCKET = 'my-codedeploy-bucket'
        CODEDEPLOY_APP = 'MyDockerApp'
        CODEDEPLOY_GROUP = 'MyDeploymentGroup'
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
                sh '''
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth
                    docker tag my-static-site:latest 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest
                    docker push 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest
                '''
            }
        }

        stage('Upload Deployment Package to S3') {
            steps {
                sh '''
                    zip -r deploy.zip appspec.yml scripts/
                    aws s3 cp deploy.zip s3://my-codedeploy-bucket-3731/
                '''
            }
        }

        stage('Trigger AWS CodeDeploy') {
            steps {
                sh '''
                    DEPLOY_ID=$(aws deploy create-deployment \
                      --application-name $CODEDEPLOY_APP \
                      --deployment-group-name $CODEDEPLOY_GROUP \
                      --s3-location bucket=$S3_BUCKET,key=deploy.zip,bundleType=zip \
                      --query "deploymentId" --output text)

                    echo "Triggered deployment: $DEPLOY_ID"
                '''
            }
        }
    }
}

