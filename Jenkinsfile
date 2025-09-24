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
          pylint sample.py | tee pylint-report.txt || true
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
    success { echo "✅ Pipeline completed successfully" }
    failure { echo "❌ Pipeline failed" }
    always  { echo "📌 Build URL: ${env.BUILD_URL}" }
  }
}
