pipeline {
    agent any

    environment {
        IMAGE_NAME = "hwijin12/apache"
        IMAGE_TAG = "latest"
        HOME = "/var/jenkins_home"  // Jenkins 기본 홈 디렉토리
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo "[INFO] GitHub 코드 체크아웃"
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "[INFO] Podman으로 이미지 빌드 시작"
                sh '''
                    # 디렉토리 생성
                    mkdir -p $HOME/.config/containers
                    mkdir -p $HOME/tmp
                    mkdir -p $HOME/.local/share/containers/run
                    mkdir -p $HOME/.local/share/containers/storage

                    # registries.conf 구성
                    cat <<EOF > $HOME/.config/containers/registries.conf
unqualified-search-registries = ["docker.io"]

[storage]
driver = "vfs"
runroot = "$HOME/.local/share/containers/run"
graphroot = "$HOME/.local/share/containers/storage"

[engine]
tmpdir = "$HOME/tmp"
runroot = "$HOME/.local/share/containers/run"

[[registry]]
prefix = "docker.io"
location = "registry-1.docker.io"
EOF

                    # 환경변수 설정
                    export XDG_RUNTIME_DIR=$HOME/tmp
                    export TMPDIR=$HOME/tmp
                    export PODMAN_TMPDIR=$HOME/tmp

                    # podman 빌드 실행
                    podman --storage-driver=vfs \
                           --root=$HOME/.local/share/containers/storage \
                           --runroot=$HOME/.local/share/containers/run \
                           --tmpdir=$HOME/tmp \
                           build -t $IMAGE_NAME:$IMAGE_TAG -f Dockerfile .
                '''
            }
        }

        stage('Push Image') {
            steps {
                echo "[INFO] DockerHub로 이미지 푸시"
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', passwordVariable: 'DOCKERHUB_PASS', usernameVariable: 'DOCKERHUB_USER')]) {
                    sh '''
                        echo $DOCKERHUB_PASS | podman login --username $DOCKERHUB_USER --password-stdin docker.io
                        podman push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Trigger Rolling Update') {
            steps {
                echo "[INFO] Apache StatefulSet 롤링 업데이트 트리거"
                sh '''
                    kubectl set image statefulset/apache apache=$IMAGE_NAME:$IMAGE_TAG --record
                '''
            }
        }
    }
}

