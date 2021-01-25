	printSubHeader "Installing postgresql..."

	#apt_get_install postgresql-9.5 postgresql-client-9.5 postgresql-common postgresql-contrib-9.5 postgresql-doc-9.5 postgresql-server-dev-9.5
	apt_get_install postgresql postgresql-contrib postgresql postgresql-client \
		libpq5 libpq-dev
	#/usr/pgsql-9.6/bin/postgresql96-setup initdb

	#echo ""
	#echo "To start PostgreSQL: systemctl start postgresql.service"
	#echo "To have PostgreSQL start on boot: systemctl enable postgresql.service"
	#echo ""
