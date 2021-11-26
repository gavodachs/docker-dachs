#!/bin/bash

PG_VERSION=$(psql --version 2> /dev/null | tr -s ' ' | cut -d' ' -f 3)
# DS_VERSION=$(dachs --version 2> /dev/null | tr -d '(-)' | cut -d' ' -f 2)
DS_VERSION=$(dpkg -l | grep 'gavodachs' | tail -n1 | tr -s ' ' | cut -d' ' -f3 | sed 's/\(.*\)+.*/\1/')
DS_VERSION=${DS_VERSION:-"2.x"}
DS_PORT=$(cat $GAVOSETTINGS | grep 'serverPort' | cut -d' ' -f2)

echo ""
echo "=========================================================="
echo "This image provides dachs & postgresql bundled together,"
echo "same scenario as you would have if installed the package,"
echo "gavodachs-server, on your own linux box"
echo ""
echo "To start DaCHS (and Postgres), type:"
echo "--------------------"
echo " $ /dachs.sh start"
echo "--------------------"
echo "It is just a convenience script to start/stop the services."
echo "See its '--help' for further information about its usage."
echo ""
echo ""
echo "After starting DaCHS, you should see it working at:"
echo " - http://localhost[:$DS_PORT]"
echo ""
echo ""
echo "Use 'gavo/dachs' as usual:"
echo "--------------------"
echo " $ dachs --help"
echo "--------------------"
echo "DaCHS documents are available at:"
echo " - http://dachs-doc.rtfd.io/tutorial.html"
echo ""
echo ""
echo "DaCHS version: $DS_VERSION"
echo "PSQL version: $PG_VERSION"
echo "=========================================================="
echo ""

#service postgresql status || service postgresql start
#dachs serve start
