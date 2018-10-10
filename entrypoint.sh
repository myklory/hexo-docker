#!/bin/bash
set -xe


# Init
#if [ ! -f "/opt/hexo/_config.yml" ];then
#	hexo init .
#	yarn install
#fi

# Deploy
if [ ! -f "/opt/hexo/deploy.sh" ];then
	cp /var/lib/hexo/deploy.sh /opt/hexo
fi

if [ ! -f "/opt/hexo/index.js" ];then
	cp /var/lib/hexo/index.js /opt/hexo/index.js
	[ -z $WEBHOOK_SECRET ] && WEBHOOK_SECRET=123456
	sed -i "s/WEBHOOK_SECRET/$WEBHOOK_SECRET/" /opt/hexo/index.js

	# Github webhook
	if [ ! -z $GITHUB ];then
		yarn add github-webhook-handler
		sed -i "s/WEBHOOK-HANDLER/github-webhook-handler/" /opt/hexo/index.js
		rm -rf /opt/hexo/source/_posts
		git clone $GITHUB 
		pm2 start index.js --name hexo
		/opt/hexo/deploy.sh
	fi

	# Gitlab webhook
	if [ ! -z $GITLAB ];then
		yarn add node-gitlab-webhook
		sed -i "s/WEBHOOK-HANDLER/node-gitlab-webhook/" /opt/hexo/index.js
		rm -rf /opt/hexo/source/_posts
		git clone $GITLAB /opt/hexo/source/_posts
		pm2 start index.js --name hexo
		/opt/hexo/deploy.sh
	fi
else
	pm2 start index.js --name hexo
	hexo clean && hexo g
fi

# Nginx
[ -z $IP_OR_DOMAIN ] && IP_OR_DOMAIN=$(hostname -i)
sed -i "s/IP_OR_DOMAIN/$IP_OR_DOMAIN/" /etc/nginx/conf.d/hexo.conf

exec "$@"
