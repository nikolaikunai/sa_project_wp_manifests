def stopPipeline = false

pipeline {
  agent { node { label 'node1' } }
  stages {
    stage('Clone repository') {
      steps {
        deleteDir()
        git url: 'https://github.com/nikolaikunai/sa_project_wp_manifests', branch: 'main'
        sh """
          ls -la
          sed -i 's+nikolaikunai/wordpress-sa.*+nikolaikunai/wordpress-sa:${DOCKERTAG}+g' wordpress/deployment.yaml
          cat wordpress/deployment.yaml
        """
      }
	  }
    stage('Testing YAML syntax') {
      steps {
        script {
          catchError (buildResult: 'FAILURE', stageResult: 'FAILURE') {
		        try {
              sh """
                chmod +x tests/check_yaml_syntax.sh
                ./tests/check_yaml_syntax.sh
              """
            }
            catch (Exception err) {
              currentBuild.result = "FAILURE"
              stopPipeline = true
              println "stopPipeline = ${stopPipeline}"
              sh "exit 1"
              }
          }  
        }
      }
    }  
    stage('Update GIT') {
      when {
        expression {
        !stopPipeline
        }
      }
      steps {
        script {
          catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
            withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
              script {
                env.encodedPass=URLEncoder.encode(PASS, "UTF-8")
              }             
              sh """
                git add .
                git commit -m "Done by Jenkins Job update manifest: ${env.BUILD_NUMBER}"
                git push https://${USER}:${encodedPass}@github.com/nikolaikunai/sa_project_wp_manifests main
              """
            }
          }
        }
      }
    }
  }
  post {
    success {
      slackSend color: '#2EB67D', 
                message: "Manifest update completed SUCCESSFULLY: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
      }
    failure {
      slackSend color: '#E01E5A', 
                message: "Manifest update completed with ERROR: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
    }
  }
}