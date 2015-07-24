#!/bin/sh

echo "Running apt-get update..."
apt-get update > /dev/null

echo "Installing OpenJDK 7 JRE..."
apt-get install openjdk-7-jre -y > /dev/null

echo "Installing nginx..."
apt-get install nginx -y > /dev/null

# Logstash related variables
LS_VERSION="1.5.2-1"
LS_URL="https://download.elastic.co/logstash/logstash/packages/debian"
LS_TARBALL="logstash_${LS_VERSION}_all.deb"

if [ -f "/home/vagrant/${LS_TARBALL}" ]; then
	echo "Skipping download of ${LS_TARBALL}"
else
	echo "Downloading ${LS_TARBALL}..."
	wget -nv "${LS_URL}/${LS_TARBALL}"
	#tar xzf ${LS_TARBALL}
fi

dpkg -i /home/vagrant/${LS_TARBALL}

# ElasticSearch related variables
ES_VERSION="1.6.0"
ES_URL="https://download.elastic.co/elasticsearch/elasticsearch"
ES_TARBALL="elasticsearch-${ES_VERSION}.deb"

ES_YML="/etc/elasticsearch/elasticsearch.yml"
ES_HTTP_CORS_ALLOW_ORIGIN="http.cors.allow-origin"
ES_HTTP_CORS_ALLOW_ORIGIN_VAL="/.*/"
ES_HTTP_CORS_ENABLED="http.cors.enabled"
ES_HTTP_CORS_ENABLED_VAL="true"

if [ -f "/home/vagrant/${ES_TARBALL}" ]; then
	echo "Skipping download of ${ES_TARBALL}"
else
	echo "Downloading ${ES_TARBALL}..."
	wget -nv "${ES_URL}/${ES_TARBALL}" > /dev/null
fi

dpkg -i /home/vagrant/${ES_TARBALL}
/usr/sbin/update-rc.d elasticsearch defaults 95 10

# Modify elasticsearch.yml for Kibana
grep "${ES_HTTP_CORS_ALLOW_ORIGIN}" ${ES_YML}
if [ "$?" != "0" ]; then
	echo "${ES_HTTP_CORS_ALLOW_ORIGIN}: \"${ES_HTTP_CORS_ALLOW_ORIGIN_VAL}\"" >> ${ES_YML}
fi

grep "${ES_HTTP_CORS_ENABLED}" ${ES_YML}
if [ "$?" != "0" ]; then
	echo "${ES_HTTP_CORS_ENABLED}: ${ES_HTTP_CORS_ENABLED_VAL}" >> ${ES_YML}
fi

mkdir -p /var/run/elasticsearch

update-rc.d elasticsearch defaults 95 10
/etc/init.d/elasticsearch start

# Download Kibana

# Kibana related variables
KI_VERSION="4.1.1"	
KI_URL="https://download.elastic.co/kibana/kibana"
KI_TARBALL="kibana-${KI_VERSION}-linux-x64.tar.gz"

if [ -f "/home/vagrant/${KI_TARBALL}" ]; then
	echo "Skipping download of ${KI_TARBALL}"
else
	echo "Downloading ${KI_TARBALL}"
	wget -nv "${KI_URL}/${KI_TARBALL}" > /dev/null
fi

echo "Installing Kibana to /home/vagrant..."
tar xzf /home/vagrant/${KI_TARBALL}
