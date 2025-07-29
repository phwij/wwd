pipeline {
  agent any
  environment {
    IMAGE_NAME = "hwijin12/apache:latest"
    TMPDIR = "/var/jenkins_home/tmp"
    RUNROOT = "/var/jenkins_home/.local/share/containers/run"
    GRAPHROOT = "/var/jenkins_home/.local/share/containers/storage"
    CONFDIR = "/var/jenkins_home/.config/containers"
  }
  stages {
    stage('Checkout Source') {
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

          echo "[[registry]]" > $CONFDIR/registries.conf
          echo "prefix = \\"docker.io\\"" >> $CONFDIR/registries.conf

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
        echo "[INFO] 이미지 푸시는 현재 생략 중"
      }
    }

    stage('Deploy to Kubernetes') {
      when {
        expression { return false }
      }
      steps {
        echo "[INFO] 배포 단계 생략됨"
      }
    }
  }

  post {
    failure {
      echo "[❌ FAILURE] 오류 발생. Console Output 확인 바랍니다."
    }
  }
}

