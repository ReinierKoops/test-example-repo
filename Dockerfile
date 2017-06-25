FROM 8-jre-alpine
MAINTAINER Reinier Koops <info@reinier.work>

COPY target/test-example-repo-1.0.0.jar \
  /home/test-example-repo-1.0.0.jar

CMD ["java","-jar","/home/test-example-repo-1.0.0.jar"]
