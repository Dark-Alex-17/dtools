filter_maven_or_gradle_installed() {
	if ! (command -v mvn > /dev/null 2>&1 || command -v gradle > /dev/null 2>&1); then
		red_bold "Maven or Gradle must be installed to run this command."
		red_bold "Please install Maven or Gradle and try again."
	fi
}