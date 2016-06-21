#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;

echo " "
echo "***************************************************"
echo Checking if GitLab has already been deployed
python mantl_utils.py applicationexists test/gitlab
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

cp sample-marathon-gitlab.json marathon-gitlab.json
#sed -i "" -e "s/DEPLOYMENTNAME/$DEPLOYMENT_NAME/g" $DEPLOYMENT_NAME-app.json
sed -i "" -e "s/MANTLDOMAIN/$MANTL_DOMAIN/g" marathon-gitlab.json
#sed -i "" -e "s/GITLABPASSWORD/$CICD_ADMIN_PASSWORD/g" marathon-gitlab.json

echo " "
echo "***************************************************"
echo Deploying GitLab
echo "** Marathon Application Definition ** "
curl -k -X POST -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps \
-H "Content-type: application/json" \
-d @test-gitlab.json \
| python -m json.tool
echo "***************************************************"
echo

