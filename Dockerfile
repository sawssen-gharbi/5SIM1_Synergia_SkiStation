FROM openjdk:8-jdk-alpine

EXPOSE 8089

ADD gestion-station-ski-1.0-RELEASE.war gestion-station-ski.jar

ENTRYPOINT ["java", "-jar", "/gestion-station-ski.jar"]
