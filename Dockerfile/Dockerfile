FROM node:8
 
MAINTAINER Last.Backend Team <team@lastbackend.com>
 
WORKDIR /usr/src/app
ADD . /usr/src/app
 
RUN apt-get update 
RUN apt-get install -y git nginx
RUN service nginx stop
RUN rm -rf node_modules
RUN npm install
RUN npm install -g bower
RUN npm install -g grunt --save-dev
 
CMD ["nginx", "-g", "daemon off;"] 
