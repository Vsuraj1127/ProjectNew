pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS-KEY') // Ensure this is a valid credential ID in Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('AWS-KEY') // Same as above
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out the code'
                git branch: 'branch1', url: 'git@github.com:Vsuraj1127/ProjectNew.git'
            }
        }

        stage('Analyze Services') {
            parallel {
                stage('Analyze Frontend') {
                    steps {
                        script {
                            dir('frontend') {
                                echo 'Analyzing the frontend'
                                sh '''
                                mvn sonar:sonar \
                                    -Dsonar.projectKey=user-service \
                                    -Dsonar.host.url=http://13.201.50.177:9000 \
                                    -Dsonar.login=${SONAR_TOKEN} \
                                    -Dsonar.java.binaries=target/classes
                                '''
                            }
                        }
                    }
                }
                stage('Analyze backend') {
                    steps {
                        script {
                            dir('backend') {
                                echo 'Analyzing the backend'
                                sh '''
                                mvn sonar:sonar \
                                    -Dsonar.projectKey=order-service \
                                    -Dsonar.host.url=http://13.201.50.177:9000 \
                                    -Dsonar.login=${SONAR_TOKEN} \
                                    -Dsonar.java.binaries=target/classes
                                '''
                            }
                        }
                    }
                }   
            }
        }
        stage('Clean Up Old Docker Images') {
            steps {
                script {
                    echo 'Cleaning up old Docker images'
                    sh 'docker rmi $(docker images)'
                    sh 'docker image prune -f'
                }
            }
        }

        stage('Docker Frontend Image Build') {
            parallel {
                stage('Build docker image for frontend') {
                    steps {
                        script {
                            dir('frontend') {
                                echo 'Building Docker Image for frontend'
                                sh 'docker build -t $FRONTEND_IMAGE .'
                            }
                        }
                    }
                }
                stage('Build Backend Docker Image') {
                    steps {
                        script {
                            dir('backend') {
                                echo 'Building Docker Image for backend'
                                sh 'docker build -t $BACKEND_IMAGE .'
                            }
                        }
                    }
                }
                stage('Build Pgsql Docker Image') {
                    steps {
                        script {
                            dir("${env.WORKSPACE}") {
                                echo 'Building Docker Image for postgressql'
                                sh 'docker build -t $PGSQL_IMAGE .'
                            }
                        }
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry(credentialsId: DOCKER_CREDENTIALS_ID) {
                        echo 'Pushing Frontend Image to Docker Hub'
                        sh 'docker push $FRONTEND_IMAGE'
                        echo 'Pushing Backend Image to Docker Hub'
                        sh 'docker push $BACKEND_IMAGE'
                        echo 'Pushing Pgsql Image to Docker Hub'
                        sh 'docker push $PGSQL_IMAGE'
                    }
                }
            }
        }

        stage('Update kubeconfig') {
            steps {
                script {
                    echo 'Updating kubeconfig for EKS'
                    sh 'aws eks update-kubeconfig --name education-eks-6SD0DFqg --region ap-south-1'
                }
            }
        }

        stage('Deploy Ingress Controller') {
            steps {
                script {
                    echo 'Deploying NGINX Ingress Controller'
                    sh 'kubectl apply -f nginx-ingress-controller.yml --validate=false'
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                script {
                    echo 'Deploying services to Kubernetes'
                    sh 'kubectl apply -f deploymentservice.yml --validate=false'
                }
            }
        }
    }

    post {
        success {
            echo 'All services built, pushed, and deployed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
