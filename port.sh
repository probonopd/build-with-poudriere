#!/bin/sh

PORT=www/firefox

PORTSDIR=/usr/ports

set -ex

pwd

cd /usr
mv ports ports.old || true
git clone --depth=1 --single-branch -b main https://github.com/freebsd/freebsd-ports.git ports

cd ${CIRRUS_WORKING_DIR}
for p in `cat list.txt`
do
	if [ -d ${PORTSDIR}/${p}/ ]; then
		rm -fr ${PORTSDIR}/${p}/*
	else
		mkdir -p ${PORTSDIR}/${p}
	fi
        cp -R ./${p}/* ${PORTSDIR}/${p}/
done

mkdir /usr/ports/distfiles

df -h

set +e
cd /usr/ports/${PORT}
make build-depends-list | cut -c 12- | xargs pkg install -y # Install all dependencies from packages
MAKE_JOBS_UNSAFE=yes make -j8
RESULT=$?
if [ ${RESULT} -eq 0 ]; then
	exit 0
fi
set -e

#TODO: Show log
#find /var/log/synth
#for i in /usr/local/poudriere/data/logs/bulk/jail-default/latest/logs/errors/*.log # FIXME: Use the above
#do
#	echo ==== $i ====
#	cat $i
#done

exit ${RESULT}
