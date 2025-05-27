pipeline {
  triggers {
    pollSCM('')
  }
  agent any
  environment {
    AWS_REGION = 'ap-south-1'
    ECR_DEV = '637423357784.dkr.ecr.ap-south-1.amazonaws.com/dev-repo'
    ECR_PROD = '637423357784.dkr.ecr.ap-south-1.amazonaws.com/prod-repo'
    IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    REMOTE_HOST = '13.233.227.189'
    REMOTE_USER = 'ubuntu'
    SSH_KEY = credentials('ec2-ssh-key')
    APP_DIR = '/home/ubuntu/app'
  }
  stages {
    stage('Checkout') {
      steps {
        git branch: "${env.BRANCH_NAME}", url: 'https://github.com/am2308/build_project.git'
      }
    }

    stage('Build & Push Image') {
      steps {
        script {
          env.TARGET_ECR = (env.BRANCH_NAME == "main") ? env.ECR_PROD : env.ECR_DEV
          sh """
            chmod +x build.sh
            ./build.sh
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
              docker-compose.yml deploy.sh \
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
            ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_FILE} ${REMOTE_USER}@${REMOTE_HOST} '
              export ECR_REPO=${TARGET_ECR}
              export IMAGE_TAG=${IMAGE_TAG}
              export AWS_REGION=${AWS_REGION}
              export APP_DIR=${APP_DIR}
              chmod +x ${APP_DIR}/deploy.sh
              ${APP_DIR}/deploy.sh
            '
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
