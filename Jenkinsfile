pipeline {
    agent any

    environment {
        IMAGE_NAME = "hwijin12/apache"
        IMAGE_TAG = "latest"
        BASE_DIR = "${env.WORKSPACE}/.podman"  // Jenkins 작업 디렉토리 내 podman 공간
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

                    echo 'unqualified-search-registries = ["docker.io"]' > $BASE_DIR/config/registries.conf
                    echo '[storage]' >> $BASE_DIR/config/registries.conf
                    echo 'driver = "vfs"' >> $BASE_DIR/config/registries.conf
                    echo "runroot = \\"$BASE_DIR/run\\"" >> $BASE_DIR/config/registries.conf
                    echo "graphroot = \\"$BASE_DIR/storage\\"" >> $BASE_DIR/config/registries.conf
                    echo '[engine]' >> $BASE_DIR/config/registries.conf
                    echo "tmpdir = \\"$BASE_DIR/tmp\\"" >> $BASE_DIR/config/registries.conf
                    echo "runroot = \\"$BASE_DIR/run\\"" >> $BASE_DIR/config/registries.conf
                    echo '[[registry]]' >> $BASE_DIR/config/registries.conf
                    echo 'prefix = "docker.io"' >> $BASE_DIR/config/registries.conf
                    echo 'location = "registry-1.docker.io"' >> $BASE_DIR/config/registries.conf

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

