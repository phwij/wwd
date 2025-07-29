pipeline {
  agent any

  environment {
    IMAGE_NAME = "hwijin12/apache:latest"
    NAMESPACE = "default"  // Apache가 배포된 네임스페이스
    TMPDIR = "/var/jenkins_home/tmp"
    XDG_RUNTIME_DIR = "/var/jenkins_home/tmp"
    PODMAN_TMPDIR = "/var/jenkins_home/tmp"
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
          mkdir -p $TMPDIR
          mkdir -p ~/.config/containers
          mkdir -p ~/.local/share/containers/run
          mkdir -p ~/.local/share/containers/storage

          # Podman storage 설정 (VFS 모드)
          cat <<EOF > ~/.config/containers/storage.conf
[storage]
driver = "vfs"
runroot = "/var/jenkins_home/.local/share/containers/run"
graphroot = "/var/jenkins_home/.local/share/containers/storage"
EOF

          # Registry 설정
          echo 'unqualified-search-registries = ["docker.io"]' > ~/.config/containers/registries.conf

          # Podman 빌드 (임시 디렉토리 강제 지정)
          TMPDIR=$TMPDIR \
          XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
          PODMAN_TMPDIR=$PODMAN_TMPDIR \
          podman --storage-driver=vfs build -t ${IMAGE_NAME} -f Dockerfile .
        '''
      }
    }

    stage('Push Image (옵션)') {
      when {
        expression { return false }  // true로 바꾸면 이미지 푸시 활성화
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
        echo "[INFO] Kubernetes에 롤링 재배포 시작"
        sh '''
          kubectl rollout restart deployment apache -n ${NAMESPACE}
        '''
      }
    }
  }

  post {
    success {
      echo '[✅ SUCCESS] 파이프라인 성공적으로 완료됨!'
    }
    failure {
      echo '[❌ FAILURE] 파이프라인 실패 - Console Output 확인 바람.'
    }
  }
}

