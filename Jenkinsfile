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
            // Stop old java project

            // Remove old java project

            // Copy new java project

            // Run new java project

            // Test if working via CURL

        }
        stage('Test approval') {
            steps {
                input message: 'I hereby declare that I am the delegate of the Scrum team and accept the changes', ok: 'Accept the latest changes to be deployed to acceptance', submitter: 'admin_dev'
            }
        }
        stage('Deploy to Acceptance') {
            // deploy image via ssh to server and curl to test
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
              echo 'Deploying....'
              // deploy update via ssh to server and curl to test
          }
        }
    }
}