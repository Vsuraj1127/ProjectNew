pipeline {
    agent any

    tools {
        nodejs 'NodeJS' // Ensure Node.js is set up
        go 'Go' // Ensure Go is set up
    }

    environment {
        FRONTEND_IMAGE = 'vsuraj1127/frontend-image:latest' // Frontend image name
        BACKEND_IMAGE = 'vsuraj1127/backend-image:latest'   // Backend image name
        PGSQL_IMAGE = 'vsuraj1127/pgsql-image:latest'       // PostgreSQL image name
        DOCKER_CREDENTIALS_ID = 'dockerhub' // Docker Hub credentials ID
        AWS_ACCESS_KEY_ID = credentials('AWS-KEY') // Ensure this is a valid credential ID in Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('AWS-KEY')

    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out the code'
                git branch: 'testing', url: 'https://github.com/Vsuraj1127/ProjectNew.git'
            }
        }

        stage('Install Dependencies') {
            parallel {
                stage('Frontend') {
                    steps {
                        dir('frontend') {
                            sh 'npm install'
                        }
                    }
                }
                stage('Backend') {
                    steps {
                        dir('backend') {
                            sh 'go mod tidy'
                        }
                    }
                }
            }
        }

        stage('Run Tests') {
            parallel {
                stage('Frontend Tests') {
                    steps {
                        dir('frontend') {
                            sh 'npm run test -- --coverage --watchAll=false || true'
                        }
                    }
                }
                stage('Backend Tests') {
                    steps {
                        dir('backend') {
                            sh 'go test -coverprofile=coverage.out ./...'
                        }
                    }
                }
            }
        }

        stage('Clean Up Old Docker Images') {
            steps {
                script {
                    echo 'Cleaning up old Docker images'
                    sh 'docker rmi $(docker images -q) || true'
                    sh 'docker image prune -f'
                }
            }
        }

        stage('Docker Image Build') {
            parallel {
                stage('Build Frontend Docker Image') {
                    steps {
                        dir('frontend') {
                            echo 'Building Docker Image for frontend'
                            sh 'docker build -t $FRONTEND_IMAGE -f Dockerfile.frontend .'
                        }
                    }
                }
                stage('Build Backend Docker Image') {
                    steps {
                        dir('backend') {
                            echo 'Building Docker Image for backend'
                            sh 'docker build -t $BACKEND_IMAGE -f Dockerfile.backend .'
                        }
                    }
                }
                stage('Build Pgsql Docker Image') {
                    steps {
                        script {
                            dir("${env.WORKSPACE}") {
                                echo 'Building Docker Image for PostgreSQL'
                                sh 'docker build -t $PGSQL_IMAGE -f Dockerfile.pgsql .'
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
                    sh 'aws eks update-kubeconfig --name education-eks-cGoeJzp8 --region ap-south-1'
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
        always {
            echo 'Cleaning up resources...'
            // Additional cleanup actions can be added here
        }
    }
}
