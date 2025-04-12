pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    ECR_DEV = '637423357784.dkr.ecr.ap-south-1.amazonaws.com/dev-repo'
    ECR_PROD = '637423357784.dkr.ecr.ap-south-1.amazonaws.com/prod-repo'
    IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    REMOTE_HOST = '13.235.254.233'
    REMOTE_USER = 'ubuntu'
    SSH_KEY = credentials('ec2-ssh-key')
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: "${env.BRANCH_NAME}", url: 'https://github.com/am2308/build_project.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t myapp:${IMAGE_TAG} .
        '''
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_DEV
        '''
      }
    }

    stage('Tag & Push Image') {
      steps {
        script {
          def targetEcr = (env.BRANCH_NAME == "main") ? env.ECR_PROD : env.ECR_DEV
          sh """
            docker tag myapp:${IMAGE_TAG} ${targetEcr}:${IMAGE_TAG}
            docker push ${targetEcr}:${IMAGE_TAG}
          """
        }
      }
    }

    stage('Deploy on EC2') {
      steps {
        script {
          def ecrUrl = (env.BRANCH_NAME == "master") ? env.ECR_PROD : env.ECR_DEV
          sh """
            ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${REMOTE_USER}@${REMOTE_HOST} '
              aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ecrUrl}
              docker pull ${targetEcr}:${IMAGE_TAG}
              docker run -d --name myapp -p 8085:80 ${targetEcr}:${IMAGE_TAG}
            '
          """
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful for ${env.BRANCH_NAME} to ${REMOTE_HOST}"
    }
    failure {
      echo "❌ Deployment failed. Check logs."
    }
  }
}
