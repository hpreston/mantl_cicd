#! /bin/bash

[ -z "$MANTL_CONTROL" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_USER" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_PASSWORD" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$MANTL_DOMAIN" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;
[ -z "$DEPLOYMENT_NAME" ] && echo "Please run 'source setup' to set Environment Variables" && exit 1;

[ -z "$GITLAB_ROOT_PASSWORD" ] && echo "Please run 'source setup_gitlab' to set Environment Variables" && exit 1;

echo "What username to create? "
read gl_username
echo
echo "What password to use? "
read -s gl_password
echo

cp sample-gitlab-user.json gitlabuser-$gl_username.json
sed -i "" -e "s/USERNAME/$gl_username/g" gitlabuser-$gl_username.json
sed -i "" -e "s/PASSWORD/$gl_password/g" gitlabuser-$gl_username.json
sed -i "" -e "s/EMAIL/$gl_username@demo.intra/g" gitlabuser-$gl_username.json
sed -i "" -e "s/FNAME/$gl_username/g" gitlabuser-$gl_username.json
sed -i "" -e "s/LNAME/DEMO/g" gitlabuser-$gl_username.json


curl -X POST -u $root:$GITLAB_ROOT_PASSWORD http://$DEPLOYMENT_NAME-gitlab.$MANTL_DOMAIN/users \
-H "Content-type: application/json" \
-d @gitlabuser-$gl_username.json \
| python -m json.tool

