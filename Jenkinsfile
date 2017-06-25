pipeline {
    agent any

    tools {
        maven "Maven_local"
        jdk "OpenJDK_8"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Get the latest version of the Jenkinsfile..'
                checkout scm
            }
        }
        stage('Build & Unittest') {
            steps {
                echo 'Running the unit tests via Cucumber..'
                sh 'mvn clean install'

                echo 'Saving it as Cucumber Report'
                step([$class: 'CucumberReportPublisher', jsonReportDirectory: 'target/cucumber', fileIncludePattern: 'cucumber.json'])
            }
        }
        stage('Static code analysis') {
            steps {
                echo 'Testing with Sonar..'
                withSonarQubeEnv('Sonar_local') {
                  sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.2:sonar'
                  }
            }
        }
        stage('Archive the Artifact') {
            steps {
                echo 'Publish build to Artifactory'
                  script {
                      def server = Artifactory.server 'Artifactory_local'
                      def rtMaven = Artifactory.newMavenBuild()

                      rtMaven.tool = 'Maven_local'
                      rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
                      rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
                      def buildInfo = Artifactory.newBuildInfo()

                      rtMaven.run pom: 'pom.xml', goals: 'clean install', buildInfo: buildInfo

                      server.publishBuildInfo buildInfo
                  }
            }
        }
        stage('Deploy to Test') {
            steps {
                sh '''#!/bin/bash -xe

                # Stop all possible old java project
                if [ -z "$(ssh 172.28.0.20 'pgrep -f test-example')" ]
                then
                      echo "No java instance running found"
                else
                      echo "A java instance was running, killing it now"
                      ssh 172.28.0.20 'pkill -f "java -jar"'
                fi

                # Clean up project directory
                ssh 172.28.0.20 'rm -rf /usr/project'
                ssh 172.28.0.20 'mkdir /usr/project'

                # Copy project from Jenkins to environment
                scp /var/jenkins_home/workspace/test-project/target/*.jar 172.28.0.20:/usr/project/

                # Run the new version of the project
                ssh 172.28.0.20 "nohup java -jar /usr/project/*.jar 1>/dev/null 2>&1 &"

                # Test if project workspace
                #response='$(curl -s -o /dev/null -w "%{http_code}" http://172.28.0.20:8080/)'
                # if response is not equal to 200, fail the build
                #if [ $response -ne 200 ]; then exit 1; fi'
                      '''
            }
        }
        stage('Test approval') {
            steps {
                input message: 'I hereby declare that I am the delegate of the Scrum team and accept the changes', ok: 'Accept the latest changes to be deployed to acceptance', submitter: 'admin_dev'
            }
        }
        stage('Deploy to Acceptance') {
            steps {
                sh '''#!/bin/bash -xe

                # Stop all possible old java project
                if [ -z "$(ssh 172.28.0.30 'pgrep -f test-example')" ]
                then
                      echo "No java instance running found"
                else
                      echo "A java instance was running, killing it now"
                      ssh 172.28.0.30 'pkill -f "java -jar"'
                fi

                # Clean up project directory
                ssh 172.28.0.30 'rm -rf /usr/project'
                ssh 172.28.0.30 'mkdir /usr/project'

                # Copy project from Jenkins to environment
                scp /var/jenkins_home/workspace/test-project/target/*.jar 172.28.0.30:/usr/project/

                # Run the new version of the project
                ssh 172.28.0.30 "nohup java -jar /usr/project/*.jar 1>/dev/null 2>&1 &"

                # Test if project workspace
                #response='$(curl -s -o /dev/null -w "%{http_code}" http://172.28.0.30:8080/)'
                # if response is not equal to 200, fail the build
                #if [ $response -ne 200 ]; then exit 1; fi'
                      '''
            }
        }
        stage('Acceptance approval') {
            steps {
                input message: 'I hereby declare that I am the (delegate of) User Acceptance Testing (UAT) and accept the changes', ok: 'Accept the latest changes', submitter: 'admin_dev'
            }
        }
        stage('Production approval') {
            steps {
                input message: 'I hereby declare that I am the (delegate of the) product owner (PO) and accept the changes', ok: 'Release to production', submitter: 'admin_dev'
            }
        }
        stage('Deploy to Production') {
            steps {
                sh '''#!/bin/bash -xe

                # Stop all possible old java project
                if [ -z "$(ssh 172.28.0.40 'pgrep -f test-example')" ]
                then
                      echo "No java instance running found"
                else
                      echo "A java instance was running, killing it now"
                      ssh 172.28.0.40 'pkill -f "java -jar"'
                fi

                # Clean up project directory
                ssh 172.28.0.40 'rm -rf /usr/project'
                ssh 172.28.0.40 'mkdir /usr/project'

                # Copy project from Jenkins to environment
                scp /var/jenkins_home/workspace/test-project/target/*.jar 172.28.0.40:/usr/project/

                # Run the new version of the project
                ssh 172.28.0.40 "nohup java -jar /usr/project/*.jar 1>/dev/null 2>&1 &"

                # Test if project workspace
                #response='$(curl -s -o /dev/null -w "%{http_code}" http://172.28.0.40:8080/)'
                # if response is not equal to 200, fail the build
                #if [ $response -ne 200 ]; then exit 1; fi'
                      '''
          }
        }
    }
}