pipeline{
    agent any
    tools{
        jdk 'jdk17'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout From Git'){
            steps{
                git branch: 'main', url: 'https://github.com/nusratdevo/system-monitoring.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Python-Webapp \
                    -Dsonar.projectKey=Python-Webapp '''
                }
            }
        }
        
        stage("TRIVY File scan"){
            steps{
                sh "trivy fs . > trivy-fs_report.txt"
            }
        }
        
        stage("Docker Build"){
            steps{
                script{
                   
                  
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                      sh 'docker build -t system-monitoring .'
                    }
                    
                    
                }
            }
        }
        
        stage("DockerImage tag & Push"){
            steps{
                script{
                    
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                       sh 'docker tag system-monitoring nusratdev/system-monitoring:${BUILD_NUMBER}'
                       sh 'docker push nusratdev/system-monitoring:${BUILD_NUMBER}'
                    }
                    
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image nusratdev/system-monitoring:${BUILD_NUMBER} > trivyimage.txt"
            }
        }
        stage("Deploy to container"){
            steps{
                sh "docker run -d --name python1 -p 5000:5000 nusratdev/system-monitoring:${BUILD_NUMBER}"
            }
        }
    }
}
