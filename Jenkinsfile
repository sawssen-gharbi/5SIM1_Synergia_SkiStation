pipeline {
    agent any

    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "192.168.33.10:8081/"
        NEXUS_REPOSITORY_RELEASE = "maven-releases"
        NEXUS_REPOSITORY_SNAPSHOT = "maven-snapshots"
        NEXUS_CREDENTIAL_ID = "sawssen_nexus_id"
    }


    stages {
        stage('GIT') {
            steps {

                sh 'git checkout sawsen'
                sh 'git pull'
                  }
        }

       stage('MVN CLEAN') {
                  steps {
                      sh "mvn clean"
                  }
              }

        stage('MVN COMPILE') {
               steps {
                 sh "mvn compile"
                    }
                }


           /*stage('MVN SONARQUBE') {
                            steps {
                                withSonarQubeEnv(installationName: 'SonarQube Server', credentialsId: 'sawssen_sonar_id') {
                                sh 'mvn sonar:sonar'
                                }
                            }
                        }*/

                          stage('MVN SONARQUBE') {
                                             steps {
                                                 sh 'mvn sonar:sonar -Dsonar.login=admin -Dsonar.password=sonar'
                                             }
                                         }

        stage('TESTS UNITAIRES MOCKITO') {
            steps {
                //sh 'mvn test'
                sh 'mvn install -Dmaven.test.skip=true'
                  }
        }

        /*stage('NEXUS'){
            steps{
                sh 'mvn deploy -Dmaven.test.skip=true'
                 }
        }*/

        stage("NEXUS ARTIFACT SNAPSHOTS") {
                                    steps {
                                        script {
                                            pom = readMavenPom file: "pom.xml";
                                            filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                                            echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                                            artifactPath = filesByGlob[0].path;
                                            artifactExists = fileExists artifactPath;
                                            if(artifactExists) {
                                                echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                                                nexusArtifactUploader(
                                                    nexusVersion: NEXUS_VERSION,
                                                    protocol: NEXUS_PROTOCOL,
                                                    nexusUrl: NEXUS_URL,
                                                    groupId: pom.groupId,
                                                    version: pom.version,
                                                    repository: NEXUS_REPOSITORY_SNAPSHOT,
                                                    credentialsId: NEXUS_CREDENTIAL_ID,
                                                    artifacts: [
                                                        [artifactId: pom.artifactId,
                                                        classifier: '',
                                                        file: artifactPath,
                                                        type: pom.packaging],
                                                        [artifactId: pom.artifactId,
                                                        classifier: '',
                                                        file: "pom.xml",
                                                        type: "pom"]
                                                    ]
                                                );

                                            } else {
                                                error "*** File: ${artifactPath}, could not be found";
                                            }
                                        }
                                    }
                                }


                stage("NEXUS ARTIFACT RELEASES") {
                    steps {

                        script {
                            sh "mvn -B release:clean release:prepare";
                            pom = readMavenPom file: "pom.xml";
                            filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                            echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                            artifactPath = filesByGlob[0].path;
                            artifactExists = fileExists artifactPath;
                            if(artifactExists) {
                                echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                                nexusArtifactUploader(
                                    nexusVersion: NEXUS_VERSION,
                                    protocol: NEXUS_PROTOCOL,
                                    nexusUrl: NEXUS_URL,
                                    groupId: pom.groupId,
                                    version: pom.version,
                                    repository: NEXUS_REPOSITORY_RELEASE,
                                    credentialsId: NEXUS_CREDENTIAL_ID,
                                    artifacts: [
                                        [artifactId: pom.artifactId,
                                        classifier: '',
                                        file: artifactPath,
                                        type: pom.packaging],
                                        [artifactId: pom.artifactId,
                                        classifier: '',
                                        file: "pom.xml",
                                        type: "pom"]
                                    ]
                                );

                            } else {
                                error "*** File: ${artifactPath}, could not be found";
                            }
                        }
                    }
                }



         stage('DOCKER BUILD') {
            steps{
                 sh 'docker build -t gestionski-devops:1.0 .'
                 }
             }

         stage('DOCKER DEPLOY') {
             steps {
                 withCredentials([string(credentialsId: 'sawssenhub_id', variable: 'DOCKERHUB_PASSWORD')]) {
                     sh 'docker login -u sawssen97 -p $DOCKERHUB_PASSWORD'
                     sh 'docker push sawssen97/gestionski-devops:1.0'
                 }
             }
         }

         stage('DOCKER COMPOSE') {
             steps {
                     sh 'docker-compose up -d'
                   }
         }


    }

    post {
        success {
            // Actions à effectuer en cas de succès
            sh 'echo "Success!"'
        }
        failure {
            // Actions à effectuer en cas d'échec
            sh 'echo "Failure!"'
        }
    }
}