cd ~
git clone https://github.com/opencord/simpleexampleservice
SIMPLEEXAMPLESERVICE_PATH=~/simpleexampleservice

USERNAME=admin@opencord.org
PASSWORD=letmein

TOSCA_URL=http://$( hostname ):30007

TOSCA_FN=$SIMPLEEXAMPLESERVICE_PATH/xos/examples/SimpleExampleServiceInstance.yaml

curl -H "xos-username: $USERNAME" -H "xos-password: $PASSWORD" -X POST --data-binary @$TOSCA_FN $TOSCA_URL/run
