FROM openjdk:8-alpine
COPY /target /usr/src/myapp/target
WORKDIR /usr/src/myapp
CMD java -jar target/*.jar
