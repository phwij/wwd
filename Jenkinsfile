pipeline {
  agent any
  environment {
    REGISTRY = "docker.io"
    IMAGE_NAME = "hwijin12/apache"
    TAG = "latest"
    FULL_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${TAG}"
  }

  stages {
    stage('Clone Source') {
      steps {
        checkout scm
      }
    }

    stage('Build with Podman') {
      steps {
        sh '''
        echo "[INFO] Building image with Podman"
        cd apache
        podman build -t $FULL_IMAGE .
        '''
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh '''
          echo "[INFO] Logging in to DockerHub"
          podman login -u $USERNAME -p $PASSWORD docker.io
          podman push $FULL_IMAGE
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
        echo "[INFO] Updating apache Deployment"
        kubectl set image deployment/apache apache=$FULL_IMAGE -n default
        '''
      }
    }

    stage('Verify Deployment') {
      steps {
        sh '''
        echo "[INFO] Waiting for rollout to finish"
        kubectl rollout status deployment/apache -n default
        '''
      }
    }
  }

  post {
    failure {
      echo '❌ Build or deploy failed!'
    }
    success {
      echo '✅ Apache deployed successfully.'
    }
  }
}


