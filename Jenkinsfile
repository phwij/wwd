pipeline {
    agent any

    environment {
        IMAGE_NAME = "hwijin12/apache"
        IMAGE_TAG = "latest"
        BASE_DIR = "${env.WORKSPACE}/.podman"  // Jenkins 작업 공간 안에 podman 디렉토리 생성
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
                    mkdir -p $BASE_DIR/tmp $BASE_DIR/run $BASE_DIR/storage $BASE_DIR/config

                    cat <<EOF > $BASE_DIR/config/registries.conf
                    unqualified-search-registries = ["docker.io"]
[storage]
driver = "vfs"
runroot = "$BASE_DIR/run"
graphroot = "$BASE_DIR/storage"

[engine]
tmpdir = "$BASE_DIR/tmp"
runroot = "$BASE_DIR/run"

[[registry]]
prefix = "docker.io"
location = "registry-1.docker.io"
EOF

                    export XDG_RUNTIME_DIR=$BASE_DIR/tmp
                    export TMPDIR=$BASE_DIR/tmp
                    export PODMAN_TMPDIR=$BASE_DIR/tmp

                    podman --storage-driver=vfs \
                           --root=$BASE_DIR/storage \
                           --runroot=$BASE_DIR/run \
                           --tmpdir=$BASE_DIR/tmp \
                           --config=$BASE_DIR/config \
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

