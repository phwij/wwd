pipeline {
  agent any

  environment {
    IMAGE_NAME = "hwijin12/apache:latest"
    NAMESPACE = "default"
  }

  stages {
    stage('Checkout') {
      steps {
        echo "[INFO] GitHub 코드 체크아웃"
        checkout scm
      }
    }

    stage('Build Image') {
      steps {
        echo "[INFO] Podman으로 이미지 빌드 시작"
        sh '''
        mkdir -p ~/.config/containers
        echo -e '[registries.search]\\nregistries = ["docker.io"]' > ~/.config/containers/registries.conf

        podman --storage-driver=vfs \
               --root $HOME/.local/share/containers/storage \
               --runroot $HOME/.local/share/containers/run \
               build -t ${IMAGE_NAME} -f Dockerfile .
        '''
      }
    }

    stage('Push Image (선택 사항)') {
      when {
        expression { return false } // 필요 시 true 로 바꾸세요
      }
      steps {
        echo "[INFO] (옵션) 이미지 푸시"
        sh '''
        podman login docker.io -u hwijin12 -p gnlwls504@
        podman push ${IMAGE_NAME} docker.io/hwijin12/apache:latest
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "[INFO] kubectl로 Deployment 재시작"
        sh '''
        kubectl rollout restart deployment apache -n ${NAMESPACE}
        '''
      }
    }
  }

  post {
    success {
      echo '[✅ SUCCESS] 파이프라인 완료!'
    }
    failure {
      echo '[❌ FAILURE] 오류 발생. 로그 확인 필요.'
    }
  }
}

