pipeline {
  agent any

  environment {
    TMPDIR = '/var/tmp'
    XDG_RUNTIME_DIR = '/var/tmp'
    PODMAN_TMPDIR = '/var/tmp'
  }

  stages {
    stage('Checkout Source') {
      steps {
        echo "[INFO] GitHub 코드 체크아웃"
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/phwij/wwd.git',
            credentialsId: 'phwij'
          ]]
        ])
      }
    }

    stage('Build Image') {
      steps {
        echo "[INFO] Podman으로 이미지 빌드 시작"
        sh '''
          mkdir -p /var/tmp /var/jenkins_home/.config/containers
          cat <<EOF > /var/jenkins_home/.config/containers/registries.conf
[registries.search]
registries = ['docker.io']

[[registry]]
prefix = "docker.io"
location = "registry-1.docker.io"
EOF

          podman --storage-driver=vfs \
            --root=/var/jenkins_home/.local/share/containers/storage \
            --runroot=/var/jenkins_home/.local/share/containers/run \
            --tmpdir=/var/tmp \
            build -t hwijin12/apache:latest -f Dockerfile .
        '''
      }
    }

    stage('Push Image (옵션)') {
      when {
        expression { return false }  // 필요 시 true로 변경
      }
      steps {
        echo "[INFO] 이미지 푸시 단계 - 생략"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "[INFO] Kubernetes에 배포 시작"
        sh 'kubectl apply -f k8s/apache.yaml'
      }
    }
  }

  post {
    failure {
      echo "[❌ FAILURE] 오류 발생. Console Output 확인 바랍니다."
    }
  }
}

