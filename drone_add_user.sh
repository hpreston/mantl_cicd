#! /bin/bash

echo
echo "To add the Development User to Drone, we need the Admin Token"
echo "please log into $DRONE_URL as $GOGS_APP_ADMIN. "
echo "Once logged in... "
echo "  1) Click the 'Profile' link under the menu in upper right corner "
echo "  2) Click the 'Show Token' button"
echo "  3) Copy the token displayed, and paste it below "
echo "     * input will be hidden"
echo
read -s drone_token

export DRONE_TOKEN="$drone_token"

echo $DRONE_TOKEN

curl -vX POST $DRONE_URL/api/users/kitty \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZXh0IjoiYnJvd25kb2ciLCJ0eXBlIjoidXNlciJ9.7GGi4Zg8UBBDKTLPvT7b7dGi_ukdyyMAAETM8N9ftBw"

curl -vX GET $DRONE_URL/api/users/browndog \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZXh0IjoiYnJvd25kb2ciLCJ0eXBlIjoidXNlciJ9.7GGi4Zg8UBBDKTLPvT7b7dGi_ukdyyMAAETM8N9ftBw"
