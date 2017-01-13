import hudson.tools.ToolInstallation;

node {
    notify('Started')
    stage 'checkout'
    git 'https://github.com/druid-rio/saofrancisco-microservices.git'

    stage'compiling, testing packaging'
    def project_path = "poc/poc-config-server"
    dir(project_path) {
        def mvnHome = "${tool 'Maven-3.3.9'}/bin"
        sh "${mvnHome}/mvn clean verify"
        stage 'archival'
        publishHTML(target: [allowMissing: true, alwaysLinkToLastBuild: false, keepAll: true, reportDir: 'target/site/jacoco', reportFiles: 'index.html', reportName: 'Code Coverage'])
        junit 'target/surefire-reports/TEST-*.xml'
        archiveArtifacts "target/*.jar"
    }
}

def notify(status){
    emailext (
      to: "gustavo.madalon@druid.com.br",
      subject: "${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
      body: """<p>${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
    )
}
