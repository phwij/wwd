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
        checkout([$class: 'GitSCM',
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
          mkdir -p "$TMPDIR" "$RUNROOT" "$GRAPHROOT" "$CONFDIR"

          cat <<EOF > $CONFDIR/containers.conf
[engine]
tmpdir = "$TMPDIR"
runroot = "$RUNROOT"
EOF

          cat <<EOF > $CONFDIR/storage.conf
[storage]
driver = "vfs"
runroot = "$RUNROOT"
graphroot = "$GRAPHROOT"
EOF

          cat <<EOF > $CONFDIR/registries.conf
unqualified-search-registries = ["docker.io"]
EOF

          TMPDIR="$TMPDIR" \
          XDG_RUNTIME_DIR="$TMPDIR" \
          PODMAN_TMPDIR="$TMPDIR" \
          podman --storage-driver=vfs build -t "$IMAGE_NAME" -f Dockerfile .
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "[INFO] Kubernetes에 배포"
        sh 'kubectl apply -f k8s/apache-deployment.yaml'
      }
    }
  }

  post {
    failure {
      echo "

