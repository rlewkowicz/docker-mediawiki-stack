node{
  stage('Update Mediawiki') {
    git 'https://github.com/rlewkowicz/docker-mediawiki-stack.git'
    sh([script: 'bash regenmediawiki' ])
  }
}
