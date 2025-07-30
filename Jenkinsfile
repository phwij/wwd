pipeline {
    agent any

    environment {
        IMAGE_NAME = "hwijin12/apache"
        IMAGE_TAG = "${new Date().format('yyyyMMdd-HHmmss')}"
        BASE_DIR = "/custom-podman"
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo "[INFO] Git 소스 체크아웃"
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "[INFO] Podman 이미지 빌드 시작"
                sh '''
                    echo "[INFO] Podman 빌드 디렉터리 준비"
                    mkdir -p $BASE_DIR/tmp $BASE_DIR/run $BASE_DIR/storage $BASE_DIR/config $BASE_DIR/containers/cache

                    export TMPDIR=$BASE_DIR/tmp
                    export PODMAN_TMPDIR=$BASE_DIR/tmp
                    export XDG_RUNTIME_DIR=$BASE_DIR/tmp
                    export _OCI_TMPDIR=$BASE_DIR/tmp
                    export CONTAINERS_STORAGE_CONF=$BASE_DIR/config/containers-storage.conf
                    export REGISTRIES_CONFIG_PATH=$BASE_DIR/config/registries.conf

                    echo "[INFO] registries.conf 생성"
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

                    echo "[INFO] containers-storage.conf 생성"
                    cat <<EOF > $BASE_DIR/config/containers-storage.conf
[storage]
driver = "vfs"
graphroot = "$BASE_DIR/storage"
runroot = "$BASE_DIR/run"
[storage.options]
additionalimagestores = []
EOF

                    echo "[INFO] Podman 빌드 실행"
                    podman --storage-driver=vfs \
                           --root=$BASE_DIR/storage \
                           --runroot=$BASE_DIR/run \
                           --tmpdir=$BASE_DIR/tmp \
                           build -t $IMAGE_NAME:$IMAGE_TAG -f Dockerfile .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "[INFO] DockerHub에 이미지 Push"
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh '''
                        echo $DOCKERHUB_PASS | podman login --username $DOCKERHUB_USER --password-stdin docker.io
                        podman push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Trigger Rolling Update') {
            steps {
                echo "[INFO] Kubernetes 롤링 업데이트 실행"
                sh '''
                    kubectl set image statefulset/apache apache=$IMAGE_NAME:$IMAGE_TAG -n default --record
                    kubectl rollout status statefulset/apache -n default
                '''
            }
        }
    }
}

