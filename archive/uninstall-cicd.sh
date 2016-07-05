#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source myhero_setup' to set Environment Variables" && exit 1;

echo Removing GitLab
curl -k -X DELETE -u $MANTL_USER:$MANTL_PASSWORD https://$MANTL_CONTROL:8080/v2/apps/cicd/drone \
-H "Content-type: application/json"
echo
