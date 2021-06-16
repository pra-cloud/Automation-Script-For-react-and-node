#!/bin/bash

service codedeploy-agent stop

rm -rfv /var/www/html/*/
#rm -rfv /var/www/html/.*/

touch /var/www/html/index.html
echo "Deleting instance" >> index.html
