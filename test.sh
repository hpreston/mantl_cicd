#! /bin/bash


echo "***************************************************"
echo "Installation completed successfully.  "
echo " "

echo "You can acess the apps at: "
echo "    Gogs:              $GOGS_URL"
echo "    Drone:             $DRONE_URL"
echo "    Docker Registry:   $REGISTRY_URL"
echo "       * Docker Registry lacks a Web UI, use docker commands to interact"
echo
echo "You can log into Gogs and Drone as either your admin user or end user accounts.  "
echo "As a reminder:  Admin User - $GOGS_APP_ADMIN "
echo "                End User   - $GOGS_APP_USER "
echo
echo "If you need their passwords you can use the following commands to retrieve them.  "
echo
echo "  These commands will only work until you close the terminal session, then the passwords are lost.  "
echo "    echo \$GOGS_APP_ADMIN_PASSWORD"
echo "    echo \$GOGS_APP_USER_PASSWORD"
echo
