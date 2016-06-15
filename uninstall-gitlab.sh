#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$DEPLOYMENT_NAME" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;

[ -z "$GITLAB_ROOT_PASSWORD" ] && echo "Please run 'source setup_gitlab' to set Environment Variables" && exit 1;
[ -z "$GITLAB_DEVUSER_PASSWORD" ] && echo "Please run 'source setup_gitlab' to set Environment Variables" && exit 1;


echo Removing GitLab
curl -k -X DELETE -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps/$DEPLOYMENT_NAME/gitlab \
-H "Content-type: application/json"
echo
