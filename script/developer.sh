#!/bin/bash -eux

if [[ ! "$DEVELOPER" = "dev" ]]; then
  exit
fi

export DEBIAN_FRONTEND=noninteractive
apt="apt-get -qq -y"

DOCKER_COMPOSE_VERSION="1.6.2"
RUBY_VERSION="2.3"
SCALA_VERSION="2.11.8"
GO_VERSION="1.6"
SWIFT_VERSION="2.2"
SWIFT_PLAT1="ubuntu1404"
SWIFT_PLAT2="ubuntu14.04"

echo " ==> Removing the OpenJDK ..."
$apt purge openjdk

echo " ==> Installing vim and curl ..."
$apt install vim curl pv
$apt install software-properties-common
$apt install clang

echo " ==> Installing PHP ..."
$apt install php5-cli
echo " ==> php version:"
php --version

echo " ==> Add git, java, maven, groovy, gradle and ruby PPAs"
apt-add-repository -y ppa:git-core/ppa
apt-add-repository -y ppa:brightbox/ruby-ng
apt-add-repository -y ppa:webupd8team/java
apt-add-repository -y ppa:andrei-pozolotin/maven3
#apt-add-repository -y ppa:groovy-dev/groovy  # This PPA does not support trusty
apt-add-repository -y ppa:cwchien/gradle
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823

echo " ==> Run an 'apt-get update' ..."
$apt update

echo " ==> Installing git ..."
$apt install git
echo " ==> git version:"
git --version

echo " ==> Installing java 8 ..."
# 'Pre-accept' the Oracle licence agreement.
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
$apt install oracle-java8-installer
echo " ==> Java version:"
java -version

# Maybe install sdkman in future for installation of groovy, gradle, scala, sbt, etc.
#echo " ==> Installing sdkman ..."
#curl -s http://get.sdkman.io | bash
#source "$HOME/.sdkman/bin/sdkman-init.sh"
#echo " ==> sdkman version:"
#sdk version

echo " ==> Installing maven ..."
$apt install maven3
#sdk install maven
echo " ==> Maven version:"
mvn -version

#echo " ==> Installing groovy ..."
#$apt install groovy
#sdk install groovy
#echo " ==> Groovy version:"
#groovy -version

echo " ==> Installing gradle ..."
apt-get -y install gradle
#sdk install gradle
echo " ==> gradle version:"
gradle -version

echo " ==> Installing Ruby ..."
$apt install ruby${RUBY_VERSION} ruby${RUBY_VERSION}-dev
echo " ==> ruby version:"
ruby --version

echo " ==> Installing Scala ..."
wget http://www.scala-lang.org/files/archive/scala-${SCALA_VERSION}.deb
dpkg -i scala-${SCALA_VERSION}.deb
echo " ==> scala version:"
scala --version

echo " ==> Installing sbt ..."
$apt install sbt
#echo " ==> sbt version:"
#sbt --version

echo " ==> Installing docker ..."
wget -qO- https://get.docker.com/ | sh
# Add any needed users to the docker group with (re-login required after, vagrant user added in vagrant.sh):
# sudo usermod -aG docker <user>
echo " ==> docker version:"
docker --version

echo " ==> Installing docker-compose ..."
curl -sL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo " ==> Installing node.js ..."
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
$apt install nodejs
echo " ==> node version:"
node --version

echo " ==> Installing Go ..."
curl -sL https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz | tar  -xz -C /usr/local
echo "export PATH=\$PATH:/usr/local/go/bin" >> /etc/profile.d/golang.sh
source /etc/profile.d/golang.sh
echo " ==> go version:"
go version

echo " ==> Installing Swift ..."
curl -sL https://swift.org/builds/swift-${SWIFT_VERSION}-release/${SWIFT_PLAT1}/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLAT2}.tar.gz | tar  -xz -C /usr/local
mv /usr/local/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLAT2}/ /usr/local/swift/
echo "export PATH=\$PATH:/usr/local/swift/usr/bin" >> /etc/profile.d/swift.sh
source /etc/profile.d/swift.sh
echo " ==> swift version:"
swift --version


echo " ==> Installed various developer tools and languages"

#echo " ==> check that the custom files have been 'provisioned'."
#ls -alF /tmp/files

tar -zxf /tmp/files/themes.tar.gz -C /usr/share/themes
echo " ==> copied new themes to correct directory."

# Inject a schema override file and then re-compile the schemas
cp /tmp/files/60_compact-theme.gschema.override /usr/share/glib-2.0/schemas
echo " ==> compiling schema changes."
glib-compile-schemas /usr/share/glib-2.0/schemas

# Set the new theme for root
echo " ==> setting the cinnamon desktop theme."
dbus-launch gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-X-Teal-alt'
dbus-launch gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-X-Teal'
dbus-launch gsettings set org.cinnamon.desktop.wm.preferences theme 'Metabox-alt'


