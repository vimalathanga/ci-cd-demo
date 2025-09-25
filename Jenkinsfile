pipeline {
  agent any
  options { timestamps() }
  triggers { pollSCM('H/5 * * * *') }

environment {
    IMAGE_NAME = 'vimalathanga/ci-cd-demo'
    DOCKERHUB = credentials('vimalathanga')
}

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup Python & Deps') {
      steps {
        sh '''
          echo "🔧 Setting up Python virtual environment..."
          python3 -m venv venv
          . venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements.txt
        '''
      }
    }

    stage('Unit Test') {
      steps {
        sh '''
          . venv/bin/activate
          pytest --junitxml=report.xml || true
        '''
        junit 'report.xml'
      }
    }

stage('Static Code Analysis') {
  steps {
    sh '''
      . venv/bin/activate
      pylint test_sample.py | tee pylint-report.txt || true
    '''
    archiveArtifacts artifacts: 'pylint-report.txt', fingerprint: true
  }
}

    stage('Docker Build & Push') {
      steps {
        sh '''
          echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
          docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
          docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
          docker push ${IMAGE_NAME}:${BUILD_NUMBER}
          docker push ${IMAGE_NAME}:latest
        '''
      }
    }

    stage('Deploy to Staging') {
      steps {
        sh '''
          if [ -x ./deploy.sh ]; then
            ./deploy.sh ${IMAGE_NAME}:${BUILD_NUMBER}
          else
            echo "⚠️ deploy.sh not present; skipping deploy."
          fi
        '''
      }
    }

    stage('Archive Artifacts') {
      steps {
        archiveArtifacts artifacts: 'report.xml', fingerprint: true
      }
    }
  }

post {
    always {
        slackSend(
            channel: '#ci-cd-alerts',
            color: '#439FE0',
            message: "📌 Job: ${env.JOB_NAME} Build: ${env.BUILD_NUMBER} started.\nURL: ${env.BUILD_URL}"
        )
    }
    success {
        slackSend(
            channel: '#ci-cd-alerts',
            color: 'good',
            message: "✅ Job: ${env.JOB_NAME} Build: ${env.BUILD_NUMBER} finished SUCCESSFULLY.\nURL: ${env.BUILD_URL}"
        )
    }
    failure {
        slackSend(
            channel: '#ci-cd-alerts',
            color: 'danger',
            message: "❌ Job: ${env.JOB_NAME} Build: ${env.BUILD_NUMBER} FAILED.\nCheck details: ${env.BUILD_URL}"
        )
    }
}
}
