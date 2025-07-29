pipeline {
    agent any

    environment {
        IMAGE_NAME = "hwijin12/apache"
        IMAGE_TAG = "latest"
        BASE_DIR = "/custom-podman"
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
                    mkdir -p $BASE_DIR/tmp
                    mkdir -p $BASE_DIR/run
                    mkdir -p $BASE_DIR/storage
                    mkdir -p $BASE_DIR/config
                    mkdir -p $BASE_DIR/containers
                    mkdir -p $BASE_DIR/containers/cache

                    # Podman이 /var/tmp를 참조하지 않도록 환경 변수로 override
                    export TMPDIR=/custom-podman/tmp
                    export PODMAN_TMPDIR=/custom-podman/tmp
                    export XDG_RUNTIME_DIR=/custom-podman/tmp
                    rm -rf /var/tmp && ln -s /custom-podman/tmp /var/tmp


                    # OCI config 등 fallback 경로용
                    export _OCI_TMPDIR=$BASE_DIR/tmp

                    # registries.conf
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

                    # 이미지 빌드
                    podman --storage-driver=vfs \
                           --root=$BASE_DIR/storage \
                           --runroot=$BASE_DIR/run \
                           --tmpdir=$BASE_DIR/tmp \
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

