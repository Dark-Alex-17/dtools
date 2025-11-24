# shellcheck disable=SC2154
declare sonar_url="${args[--sonar-url]}"
declare sonar_login="${args[--sonar-login]}"
declare sonar_project_key="${args[--sonar-project-key]}"

if [[ -f pom.xml ]]; then
	mvn sonar:sonar \
    -Dsonar.projectKey="$sonar_project_key" \
    -Dsonar.host.url="$sonar_url" \
    -Dsonar.login="sonar_login"
elif [[ -f settings.gradle ]]; then
	if (grep -q plugins build.gradle); then
		sed '/plugins/a id "org.sonarqube" version "5.0.0.4638"' build.gradle
	fi

	./gradlew sonar \
    -Dsonar.projectKey="$sonar_project_key" \
    -Dsonar.host.url="$sonar_url" \
    -Dsonar.login="$sonar_login"
fi
