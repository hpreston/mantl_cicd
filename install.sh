#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$DEPLOYMENT_NAME" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$VOLUME_PATH" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;

[ -z "$GOGS_APP_NAME" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$GOGS_URL" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;


##############################################################
# Check if Gogs has already been deployed
echo " "
echo "***************************************************"
echo Checking if Gogs has already been deployed
python mantl_utils.py applicationexists $DEPLOYMENT_NAME/gogs
if [ $? -eq 1 ]
then
    echo "    Not already installed, continuing."
else
    echo "    Already Installed."
    echo "    Exiting"
    exit 1
fi

##############################################################
# Create Copy of JSON Definitions for Deployment
echo "Creating Application Definition Files "

# Gogs
cp templates/sample-marathon-gogs.json $DEPLOYMENT_NAME-gogs.json
sed -i "" -e "s/DEPLOYMENTNAME/$DEPLOYMENT_NAME/g" $DEPLOYMENT_NAME-gogs.json
sed -i "" -e "s/MANTLDOMAIN/$MANTL_DOMAIN/g" $DEPLOYMENT_NAME-gogs.json
sed -i "" -e "s/VOLUMEPATH/$VOLUME_PATH/g" $DEPLOYMENT_NAME-gogs.json

# Drone
cp templates/sample-marathon-drone-gogs.json $DEPLOYMENT_NAME-drone.json
sed -i "" -e "s/DEPLOYMENTNAME/$DEPLOYMENT_NAME/g" $DEPLOYMENT_NAME-drone.json
sed -i "" -e "s/MANTLDOMAIN/$MANTL_DOMAIN/g" $DEPLOYMENT_NAME-drone.json
sed -i "" -e "s/VOLUMEPATH/$VOLUME_PATH/g" $DEPLOYMENT_NAME-drone.json


# Registry
cp templates/sample-marathon-registry.json $DEPLOYMENT_NAME-registry.json
sed -i "" -e "s/DEPLOYMENTNAME/$DEPLOYMENT_NAME/g" $DEPLOYMENT_NAME-registry.json
sed -i "" -e "s/MANTLDOMAIN/$MANTL_DOMAIN/g" $DEPLOYMENT_NAME-registry.json
sed -i "" -e "s/VOLUMEPATH/$VOLUME_PATH/g" $DEPLOYMENT_NAME-registry.json


##############################################################
# Deploy Gogs

echo " "
echo "***************************************************"
echo Deploying Gogs

curl -k -X POST -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps \
  -o log-gogs-deploy.txt \
  -H "Content-type: application/json" \
  -d @$DEPLOYMENT_NAME-gogs.json
echo "***************************************************"
echo


##############################################################
# 0) deploy registry

echo " "
echo "***************************************************"
echo Deploying Registry

curl -k -X POST -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps \
  -o log-registry-deploy.txt \
  -H "Content-type: application/json" \
  -d @$DEPLOYMENT_NAME-registry.json
echo "***************************************************"
echo


##############################################################
# 1) check if gogs is up

echo "Checking if Gogs is up"
HTTP_STATUS=$(curl -sL -w "%{http_code}" "$GOGS_URL" -o /dev/null)
while [ $HTTP_STATUS -ne 200 ]
do
    HTTP_STATUS=$(curl -sL -w "%{http_code}" "$GOGS_URL" -o /dev/null)
    echo "Gogs not up yet, checking again in 30 seconds. "
    sleep 30
done
echo
echo "Gogs is up.  Beginning Configuraiton"
echo


##############################################################
# 2) configure gogs
#curl -vX POST $GOGS_URL/install -H "Content-Type: application/x-www-form-urlencoded" -d "db_type=SQLite3&db_host=127.0.0.1:3306&db_user=root&db_passwd=&db_name=gogs&ssl_mode=disable&db_path=data/gogs.db&app_name=$GOGS_APP_NAME&repo_root_path=/data/git/gogs-repositories&run_user=git&domain=localhost&ssh_port=22&http_port=3000&app_url=http://$DEPLOYMENT_NAME-gogs.$MANTL_DOMAIN/&log_root_path=/app/gogs/log&smtp_host=&smtp_from=&smtp_email=&smtp_passwd=&enable_captcha=on&admin_name=$GOGS_APP_ADMIN&admin_passwd=$GOGS_APP_ADMIN_PASSWORD&admin_confirm_passwd=$GOGS_APP_ADMIN_PASSWORD&admin_email=$GOGS_APP_ADMIN_EMAIL"
HTTP_STATUS=$(curl -X POST -sL -w "%{http_code}" "$GOGS_URL/install" -o log-gogs-config.txt -H "Content-Type: application/x-www-form-urlencoded" -d "db_type=SQLite3&db_host=127.0.0.1:3306&db_user=root&db_passwd=&db_name=gogs&ssl_mode=disable&db_path=data/gogs.db&app_name=$GOGS_APP_NAME&repo_root_path=/data/git/gogs-repositories&run_user=git&domain=localhost&ssh_port=22&http_port=3000&app_url=http://$DEPLOYMENT_NAME-gogs.$MANTL_DOMAIN/&log_root_path=/app/gogs/log&smtp_host=&smtp_from=&smtp_email=&smtp_passwd=&enable_captcha=on&admin_name=$GOGS_APP_ADMIN&admin_passwd=$GOGS_APP_ADMIN_PASSWORD&admin_confirm_passwd=$GOGS_APP_ADMIN_PASSWORD&admin_email=$GOGS_APP_ADMIN_EMAIL")

if [ $HTTP_STATUS -eq 200 ]
then
    echo "Gogs has been configured successfully."
    echo " "
    echo "Moving onto create new Gogs Users.  "
    echo
else
    echo "    Exiting"
    exit 1

fi


##############################################################
# 3) add gogs users
HTTP_STATUS=$(curl -X POST -sL -w "%{http_code}" -u $GOGS_APP_ADMIN:$GOGS_APP_ADMIN_PASSWORD "$GOGS_URL/api/v1/admin/users" -o log-gogs-users.txt -H "Content-Type: application/json" -d "{\"username\":\"$GOGS_APP_USER\",\"email\":\"$GOGS_APP_USER_EMAIL\",\"password\":\"$GOGS_APP_USER_PASSWORD\"}")

if [ $HTTP_STATUS -eq 201 ]
then
    echo "Development End User added to Gogs successfully."
    echo " "
    echo "Moving onto deploy Drone.  "
else
    echo "*** Error during configuration."
    echo "    Exiting"
    exit 1
fi


##############################################################
# 4) deploy drone

#curl -k -X POST -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps \
#-H "Content-type: application/json" \
#-d @$DEPLOYMENT_NAME-drone.json \
#| python -m json.tool

echo " "
echo "***************************************************"
echo Deploying Drone

curl -k -X POST -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps \
  -o log-drone-deploy.txt \
  -H "Content-type: application/json" \
  -d @$DEPLOYMENT_NAME-drone.json
echo "***************************************************"
echo



##############################################################
# 5) check if drone is up

echo "Checking if Drone is up"
HTTP_STATUS=$(curl -sL -w "%{http_code}" "$DRONE_URL/authorize" -o /dev/null)
while [ $HTTP_STATUS -ne 200 ]
do
    HTTP_STATUS=$(curl -sL -w "%{http_code}" "$DRONE_URL/authorize" -o /dev/null)
    echo "Drone not up yet, checking again in 30 seconds. "
    sleep 30
done
echo " "
echo "Drone is up.  Beginning Configuraiton"
echo


##############################################################
# 6) log into drone as admin

echo "***************************************************"
echo "Registrying Development Admin User with Drone."

curl -X POST $DRONE_URL/authorize \
  -o log-drone-adminreg.txt \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$GOGS_APP_ADMIN&password=$GOGS_APP_ADMIN_PASSWORD"

#HTTP_STATUS=$(curl -sL -w "%{http_code}" -X POST http://$DEPLOYMENT_NAME-drone.$MANTL_DOMAIN/authorize -o log-drone-adminreg.txt -H "Content-Type: application/x-www-form-urlencoded" -d "username=$GOGS_APP_ADMIN&password=$GOGS_APP_ADMIN_PASSWORD")

echo
echo "Drone admin configured"
echo

##############################################################
# 7) add drone users
