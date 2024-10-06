def VERSION='1.0.0'
pipeline {
    agent any
    environment {
        PROJECT = "WELCOME TO TECHVERITO APP"
    }
    stages {
        stage('Clone Repository') {
            steps {
               git branch: 'main', url: 'git@github.com:Saipavangit1997/Techverito-app.git'
            }       
        }
        stage("Docker Verification") {
            when {
                branch 'main'
            }
            agent { label 'PROD' }
            steps {
                sh "docker version"
                sh "docker-compose version"
            }
        }
        stage("Build") {
            when {
                branch 'main'
            }
            agent { label 'PROD' }
            steps {
                sh "docker-compose build --no-cache"
            }
        }
        stage("Deploy") {
            when {
                branch 'main'
            }
            agent { label 'PROD' }
            steps {
                sh "docker-compose up -d"
            }
        }
    }
}
