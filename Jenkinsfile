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
    APP_DIR = '/home/ubuntu/app'  // Remote directory on EC2
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: "${env.BRANCH_NAME}", url: 'https://github.com/am2308/build_project.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t myapp:${IMAGE_TAG} .'
      }
    }

    stage('Login to ECR') {
      steps {
        script {
          env.TARGET_ECR = (env.BRANCH_NAME == "main") ? env.ECR_PROD : env.ECR_DEV
          sh """
            aws ecr get-login-password --region ${AWS_REGION} | \
            docker login --username AWS --password-stdin ${TARGET_ECR}
          """
        }
      }
    }

    stage('Tag & Push Image') {
      steps {
        script {
          env.TARGET_ECR = (env.BRANCH_NAME == "main") ? env.ECR_PROD : env.ECR_DEV
          sh """
            docker tag myapp:${IMAGE_TAG} ${env.TARGET_ECR}:${IMAGE_TAG}
            docker push ${env.TARGET_ECR}:${IMAGE_TAG}
          """
        }
      }
    }

    stage('Prepare EC2') {
      steps {
        withCredentials([sshUserPrivateKey(
          credentialsId: 'ec2-ssh-key',
          keyFileVariable: 'SSH_KEY_FILE'
        )]) {
          sh """
            ssh -o StrictHostKeyChecking=no \
              -i ${SSH_KEY_FILE} \
              ${REMOTE_USER}@${REMOTE_HOST} \
              "mkdir -p ${APP_DIR} && chmod 777 ${APP_DIR}"
          """
        }
      }
    }

    stage('Transfer Files') {
      steps {
        withCredentials([sshUserPrivateKey(
          credentialsId: 'ec2-ssh-key',
          keyFileVariable: 'SSH_KEY_FILE'
        )]) {
          sh """
            scp -o StrictHostKeyChecking=no \
              -i ${SSH_KEY_FILE} \
              docker-compose.yml \
              ${REMOTE_USER}@${REMOTE_HOST}:${APP_DIR}/
          """
        }
      }
    }

    stage('Deploy on EC2') {
      steps {
        withCredentials([sshUserPrivateKey(
          credentialsId: 'ec2-ssh-key',
          keyFileVariable: 'SSH_KEY_FILE'
        )]) {
          sh """
            # Deploy with environment variables
            ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${REMOTE_USER}@${REMOTE_HOST} \
              "cd ${APP_DIR} && \
               export ECR_REPO=${TARGET_ECR} && \
               export IMAGE_TAG=${IMAGE_TAG} && \
               aws ecr get-login-password --region ${AWS_REGION} | \
               docker login --username AWS --password-stdin ${TARGET_ECR} && \
               docker-compose down && \
               docker-compose pull && \
               docker-compose up -d"
          """
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful! Access at: http://${REMOTE_HOST}"
    }
    failure {
      echo "❌ Deployment failed. Check logs."
    }
  }
}
