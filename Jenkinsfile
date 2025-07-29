pipeline {
  agent any

  environment {
    IMAGE_NAME = "hwijin12/apache:latest"
    NAMESPACE = "default" // apache가 배포된 네임스페이스
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

          # 정확한 TOML 형식의 storage.conf 작성 (runroot, graphroot 직접 선언)
          cat <<EOF > ~/.config/containers/storage.conf
[storage]
driver = "vfs"
runroot = "/var/jenkins_home/.local/share/containers/run"
graphroot = "/var/jenkins_home/.local/share/containers/storage"
EOF

          # registry 설정 (short name 사용 가능)
          cat <<EOF > ~/.config/containers/registries.conf
unqualified-search-registries = ["docker.io"]
EOF

          # 이미지 빌드 실행
          podman --storage-driver=vfs build -t ${IMAGE_NAME} -f Dockerfile .
        '''
      }
    }

    stage('Push Image (옵션)') {
      when {
        expression { return false } // true로 바꾸면 푸시 활성화
      }
      steps {
        echo "[INFO] 이미지 푸시"
        sh '''
          podman login quay.io -u <your-username> -p <your-password>
          podman push ${IMAGE_NAME} quay.io/<your-username>/apache:latest
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "[INFO] Deployment 롤링 재시작"
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
      echo '[❌ FAILURE] 오류 발생. Console Output 확인 바랍니다.'
    }
  }
}

