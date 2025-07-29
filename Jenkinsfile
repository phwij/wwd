pipeline {
  agent any

  environment {
    IMAGE_NAME = 'hwijin12/apache:latest'
    CONTAINER_TMPDIR = '/var/jenkins_home/tmp'
    CONTAINER_RUNDIR = '/var/jenkins_home/.local/share/containers/run'
    CONTAINER_GRAPHROOT = '/var/jenkins_home/.local/share/containers/storage'
    CONTAINER_CONF = '/var/jenkins_home/.config/containers'
    CONTAINER_RUNTIME_DIR = '/var/jenkins_home/runtime-dir'
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
          mkdir -p $CONTAINER_RUNTIME_DIR
          chown -R $(id -u):$(id -g) $CONTAINER_RUNTIME_DIR

          mkdir -p $CONTAINER_CONF
          cat <<EOF > $CONTAINER_CONF/registries.conf
[registries.search]
registries = ['docker.io']

[[registry]]
prefix = "docker.io"
location = "registry-1.docker.io"
EOF

          mkdir -p $CONTAINER_TMPDIR $CONTAINER_RUNDIR $CONTAINER_GRAPHROOT

          XDG_RUNTIME_DIR=$CONTAINER_RUNTIME_DIR \
          TMPDIR=$CONTAINER_TMPDIR \
          podman --storage-driver=vfs \
            --root=$CONTAINER_GRAPHROOT \
            --runroot=$CONTAINER_RUNDIR \
            --tmpdir=$CONTAINER_TMPDIR \
            build -t $IMAGE_NAME -f Dockerfile .
        '''
      }
    }

    stage('Push Image (옵션)') {
      when {
        expression { return false } // 필요시 true로 변경 후 push 추가
      }
      steps {
        echo "[INFO] (옵션) 이미지 푸시 단계"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "[INFO] (옵션) Kubernetes 배포 단계 - 필요한 경우 적용"
      }
    }
  }

  post {
    failure {
      echo "[❌ FAILURE] 오류 발생. Console Output 확인 바랍니다."
    }
  }
}

