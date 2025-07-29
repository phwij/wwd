pipeline {
  agent any

  environment {
    IMAGE_NAME = "hwijin12/apache:latest"
    NAMESPACE = "default"
    TMPDIR = "/var/jenkins_home/tmp"
    RUNROOT = "/var/jenkins_home/.local/share/containers/run"
    GRAPHROOT = "/var/jenkins_home/.local/share/containers/storage"
    CONFDIR = "/var/jenkins_home/.config/containers"
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
          mkdir -p "$TMPDIR" "$RUNROOT" "$GRAPHROOT" "$CONFDIR"

          echo "[storage]" > $CONFDIR/storage.conf
          echo "driver = \\"vfs\\"" >> $CONFDIR/storage.conf
          echo "runroot = \\"$RUNROOT\\"" >> $CONFDIR/storage.conf
          echo "graphroot = \\"$GRAPHROOT\\"" >> $CONFDIR/storage.conf

          echo "[engine]" > $CONFDIR/containers.conf
          echo "tmpdir = \\"$TMPDIR\\"" >> $CONFDIR/containers.conf
          echo "runroot = \\"$RUNROOT\\"" >> $CONFDIR/containers.conf

          echo 'unqualified-search-registries = ["docker.io"]' > $CONFDIR/registries.conf
          echo '' >> $CONFDIR/registries.conf
          echo '[[registry]]' >> $CONFDIR/registries.conf
          echo 'prefix = "docker.io"' >> $CONFDIR/registries.conf
          echo 'location = "registry-1.docker.io"' >> $CONFDIR/registries.conf

          rm -rf "$GRAPHROOT"/* || true
          rm -rf "$RUNROOT"/* || true

          TMPDIR="$TMPDIR" \
          XDG_RUNTIME_DIR="$TMPDIR" \
          PODMAN_TMPDIR="$TMPDIR" \
          podman --storage-driver=vfs build -t "$IMAGE_NAME" -f Dockerfile .
        '''
      }
    }

    stage('Push Image (옵션)') {
      when {
        expression { return false }
      }
      steps {
        echo "[INFO] 이미지 푸시"
        sh '''
          podman login quay.io -u <your-username> -p <your-password>
          podman push "$IMAGE_NAME" quay.io/<your-username>/apache:latest
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "[INFO] Kubernetes 배포 롤링 재시작"
        sh '''
          kubectl rollout restart deployment apache -n "$NAMESPACE"
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

