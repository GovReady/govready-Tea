#!/bin/sh

if [ ! -f /etc/yum.repos.d/epel-6-scap-security-guide.repo ]
then
	echo "SCAP security guide repo not installed, installing"

  wget -O /etc/yum.repos.d/epel-6-scap-security-guide.repo \
		http://repos.fedorapeople.org/repos/scap-security-guide/epel-6-scap-security-guide.repo
fi

if [ ! -f /etc/yum.repos.d/epel-6-openscap.repo ]
then
	echo "OpenSCAP repo not installed, installing"

	wget -O /etc/yum.repos.d/epel-6-openscap.repo \
		http://repos.fedorapeople.org/repos/gitopenscap/openscap/epel-6-openscap.repo
fi

rpm -q scap-security-guide > /dev/null
if [ $? -ne 0 ]
then
	echo "scap-security-guide not installed, installing"
	yum -y install scap-security-guide
fi
