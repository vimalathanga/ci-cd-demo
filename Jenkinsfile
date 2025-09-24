pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/vimalathanga/ci-cd-demo.git'
            }
        }

        stage('Build') {
            steps {
                sh 'echo "Simulating Python build step"'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'pytest --junitxml=report.xml || true'
                junit 'report.xml'
            }
        }

        stage('Static Code Analysis') {
            steps {
                sh 'pylint sample.py || true'
            }
        }

        stage('Docker Build & Push') {
            environment {
                DOCKERHUB = credentials('dockerhub-creds')
            }
            steps {
                sh '''
                  echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
                  docker build -t vimalathanga/ci-cd-demo:${BUILD_NUMBER} .
                  docker push vimalathanga/ci-cd-demo:${BUILD_NUMBER}
                '''
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh './deploy.sh || echo "No deploy script yet"'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'report.xml', fingerprint: true
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully ✅"
        }
        failure {
            echo "Pipeline failed ❌"
        }
    }
}
