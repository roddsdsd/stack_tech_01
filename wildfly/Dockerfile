# Etapa 1 · Maven: compila monitor.war y descarga el driver JDBC
FROM maven:3.9-eclipse-temurin-21 AS compilacion
WORKDIR /src
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package \
 && mvn -B -q dependency:copy -Dartifact=com.microsoft.sqlserver:mssql-jdbc:12.8.1.jre11 \
        -DoutputDirectory=/drivers -Dmdep.stripVersion=true

# Etapa 2 · WildFly: configura driver y DataSource y despliega el WAR
FROM quay.io/wildfly/wildfly:35.0.1.Final-jdk21
COPY --from=compilacion /drivers/mssql-jdbc.jar /tmp/mssql-jdbc.jar
COPY configurar.cli /tmp/configurar.cli
RUN /opt/jboss/wildfly/bin/jboss-cli.sh --file=/tmp/configurar.cli \
 && rm -rf /opt/jboss/wildfly/standalone/configuration/standalone_xml_history

# Lo que hay en deployments se despliega al arrancar
COPY --from=compilacion --chown=jboss:jboss /src/target/monitor.war /opt/jboss/wildfly/standalone/deployments/

EXPOSE 8080
