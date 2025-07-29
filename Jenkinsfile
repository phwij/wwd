pipeline {
    agent any

    environment {
        IMAGE_NAME = "hwijin12/apache"
        IMAGE_TAG = "latest"
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
                    mkdir -p /var/jenkins_home/tmp /var/jenkins_home/.local/share/containers/run /var/jenkins_home/.local/share/containers/storage /var/jenkins_home/.config/containers
                    cat <<EOF > /var/jenkins_home/.config/containers/registries.conf
[storage]
driver = "vfs"
runroot = "/var/jenkins_home/.local/share/containers/run"
graphroot = "/var/jenkins_home/.local/share/containers/storage"

[engine]
tmpdir = "/var/jenkins_home/tmp"
runroot = "/var/jenkins_home/.local/share/containers/run"

[[registry]]
prefix = "docker.io"
location = "registry-1.docker.io"
EOF

                    XDG_RUNTIME_DIR=/var/jenkins_home/tmp TMPDIR=/var/jenkins_home/tmp \
                    podman --storage-driver=vfs \
                           --root=/var/jenkins_home/.local/share/containers/storage \
                           --runroot=/var/jenkins_home/.local/share/containers/run \
                           --tmpdir=/var/jenkins_home/tmp \
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

