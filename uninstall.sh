#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$DEPLOYMENT_NAME" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$VOLUME_PATH" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;

[ -z "$GOGS_APP_NAME" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$GOGS_URL" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;


echo Removing Drone
curl -k -X DELETE -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps/$DEPLOYMENT_NAME/drone \
-H "Content-type: application/json"
echo

echo Removing Registry
curl -k -X DELETE -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps/$DEPLOYMENT_NAME/registry \
-H "Content-type: application/json"
echo

echo Removing Gogs
curl -k -X DELETE -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps/$DEPLOYMENT_NAME/gogs \
-H "Content-type: application/json"
echo

echo "CICD Deployment has been removed from Marathon"
echo
echo "** To completely uninstall, you will need to delete the "
echo "   volumes on the worker nodes.  If you do NOT delete them "
echo "   and re-deploy with the same deployment name, your data "
echo "   will all remain.  **"
echo " "



