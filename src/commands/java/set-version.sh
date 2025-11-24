sudo rm /usr/bin/java
sudo rm /usr/bin/javac
sudo rm /usr/bin/javadoc
sudo rm /usr/bin/javah
sudo rm /usr/bin/javap

declare basePath=/usr/lib/jvm
# shellcheck disable=SC2154
declare version="${args[version]}"

case $version in
  8)
  	declare jdk8Path="$basePath/java-8-openjdk-amd64/bin"
  	sudo ln -s "$jdk8Path/java" /usr/bin/java
  	sudo ln -s "$jdk8Path/javac" /usr/bin/javac
  	sudo ln -s "$jdk8Path/javadoc" /usr/bin/javadoc
  	sudo ln -s "$jdk8Path/javah" /usr/bin/javah
  	sudo ln -s "$jdk8Path/javap" /usr/bin/javap
  	;;
  11)
  	declare jdk11Path="$basePath/java-11-openjdk-amd64/bin"
  	sudo ln -s "$jdk11Path/java" /usr/bin/java
  	sudo ln -s "$jdk11Path/javac" /usr/bin/javac
  	sudo ln -s "$jdk11Path/javadoc" /usr/bin/javadoc
  	sudo ln -s "$jdk11Path/javah" /usr/bin/javah
  	sudo ln -s "$jdk11Path/javap" /usr/bin/javap
  	;;
  17)
  	declare jdk17Path="$basePath/java-17-openjdk-amd64/bin"
  	sudo ln -s "$jdk17Path/java" /usr/bin/java
  	sudo ln -s "$jdk17Path/javac" /usr/bin/javac
  	sudo ln -s "$jdk17Path/javadoc" /usr/bin/javadoc
  	sudo ln -s "$jdk17Path/javah" /usr/bin/javah
  	sudo ln -s "$jdk17Path/javap" /usr/bin/javap
  	;;
  21)
  	declare jdk21Path="$basePath/java-21-openjdk-amd64/bin"
  	sudo ln -s "$jdk21Path/java" /usr/bin/java
  	sudo ln -s "$jdk21Path/javac" /usr/bin/javac
  	sudo ln -s "$jdk21Path/javadoc" /usr/bin/javadoc
  	sudo ln -s "$jdk21Path/javah" /usr/bin/javah
  	sudo ln -s "$jdk21Path/javap" /usr/bin/javap
  	;;
esac
