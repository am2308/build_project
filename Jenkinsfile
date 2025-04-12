pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    ECR_DEV = '637423357784.dkr.ecr.ap-south-1.amazonaws.com/dev-repo'
    ECR_PROD = '637423357784.dkr.ecr.ap-south-1.amazonaws.com/prod-repo'
    IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    REMOTE_HOST = '13.235.254.233'
    REMOTE_USER = 'ubuntu'
    SSH_KEY = credentials('ec2-ssh-key')  // SSH key added in Jenkins
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
          def targetEcr = (env.BRANCH_NAME == "master") ? env.ECR_PROD : env.ECR_DEV
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
          def deployScript = """
            ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'
            export IMAGE_TAG=${IMAGE_TAG}
            export ECR_URL=$((BRANCH_NAME == "master") ? "$ECR_PROD" : "$ECR_DEV")
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $ECR_URL
            cd /home/ec2-user/app && docker-compose pull
EOF
          """

          sh deployScript
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful for ${BRANCH_NAME} to ${REMOTE_HOST}"
    }
    failure {
      echo "❌ Deployment failed. Check logs."
    }
  }
}
