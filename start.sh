#!/bin/bash

if [ -z "$( ls -A '/app/dpa' )" ]; then
    echo "Copying default installation..."
    rsync -ah --progress /app/dpa_*/* /app/dpa
else
    echo "Existing installation detected"
fi

touch /app/dpa/iwc/tomcat/logs/catalina.out
/app/dpa/startup.sh
exec /usr/bin/tail -n 250 --follow=name /app/dpa/iwc/tomcat/logs/catalina.out