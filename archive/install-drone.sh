#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;

[ -z "$GITLAB_CLIENT_ID" ] && echo "Please run 'source setup_drone' to set Environment Variables" && exit 1;
[ -z "$GITLAB_CLIENT_SECRET" ] && echo "Please run 'source setup_drone' to set Environment Variables" && exit 1;

echo " "
echo "***************************************************"
echo Checking if Drone has already been deployed
python mantl_utils.py applicationexists cicd/drone
if [ $? -eq 1 ]
then
    echo "    Not already installed, continuing."
else
    echo "    Already Installed."
    echo "    Exiting"
    exit 1
fi

# Create Copy of JSON Definitions for Deployment
echo "Creating Application Definifition "

cp sample-marathon-drone-gitlab.json marathon-drone.json
#sed -i "" -e "s/DEPLOYMENTNAME/$DEPLOYMENT_NAME/g" marathon-drone.json
sed -i "" -e "s/MANTLDOMAIN/$MANTL_DOMAIN/g" marathon-drone.json
sed -i "" -e "s/GITCLIENTID/$GITLAB_CLIENT_ID/g" marathon-drone.json
sed -i "" -e "s/GITCLIENTSECRET/$GITLAB_CLIENT_SECRET/g" marathon-drone.json

echo " "
echo "***************************************************"
echo Deploying Drone
echo "** Marathon Application Definition ** "
curl -k -X POST -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps \
-H "Content-type: application/json" \
-d @marathon-drone.json \
| python -m json.tool
echo "***************************************************"
echo
