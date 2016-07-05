#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$DEPLOYMENT_NAME" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;

[ -z "$GITLAB_ROOT_PASSWORD" ] && echo "Please run 'source setup_gitlab' to set Environment Variables" && exit 1;
[ -z "$GITLAB_DEVUSER_PASSWORD" ] && echo "Please run 'source setup_gitlab' to set Environment Variables" && exit 1;


echo " "
echo "***************************************************"
echo Checking if GitLab has already been deployed
python mantl_utils.py applicationexists $DEPLOYMENT_NAME/gitlab
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

cp sample-marathon-gitlab.json $DEPLOYMENT_NAME-gitlab.json
sed -i "" -e "s/DEPLOYMENTNAME/$DEPLOYMENT_NAME/g" $DEPLOYMENT_NAME-gitlab.json
sed -i "" -e "s/MANTLDOMAIN/$MANTL_DOMAIN/g" $DEPLOYMENT_NAME-gitlab.json
sed -i "" -e "s/GITLABPASSWORD/$GITLAB_ROOT_PASSWORD/g" $DEPLOYMENT_NAME-gitlab.json

echo " "
echo "***************************************************"
echo Deploying GitLab
echo "** Marathon Application Definition ** "
curl -k -X POST -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps \
-H "Content-type: application/json" \
-d @$DEPLOYMENT_NAME-gitlab.json \
| python -m json.tool
echo "***************************************************"
echo

echo "Checking if GitLab is up"
HTTP_STATUS=$(curl -sL -w "%{http_code}" "http://$DEPLOYMENT_NAME-gitlab.$MANTL_DOMAIN" -o /dev/null)
while [ $HTTP_STATUS -ne 200 ]
do
    HTTP_STATUS=$(curl -sL -w "%{http_code}" "http://$DEPLOYMENT_NAME-gitlab.$MANTL_DOMAIN" -o /dev/null)
    echo "GitLab not up yet, checking again in 30 seconds. "
    sleep 30
done
echo "GitLab is up.  Beginning Configuraiton"

# Create new user