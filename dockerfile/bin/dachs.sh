#!/bin/bash

echo 'This image is meant to be a default option for GAVO/DaCHS.'
echo 'It has the dachs & postgresql server bundled together,'
echo 'same scenario as you would have if installed the package,'
echo 'gavodachs-server, on your own bare machine'
echo 'That said:'
echo ' - this container exposes port 80'
echo ' - data may go in /var/gavo/inputs'
echo 'To run the services, the usual:'
echo ' - service postgresql start'
echo ' - service dachs start'
echo 'You should now be able to see the web interface on your'
echo 'docker host operating system at "http://localhost",'
echo 'considering you made the mapping of ports 80->80'

