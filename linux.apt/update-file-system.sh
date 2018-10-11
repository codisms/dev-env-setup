#	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
#		[ ! -f /etc/fstab.orig ] && cp /etc/fstab /etc/fstab.orig
#		cp -R /root/* /data/ || true
#		cp .* /data/ || true
#		cp -R /root/.ssh /data/ || true
#		cp -R /root/.setup /data/ || true
#		sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
#	fi
