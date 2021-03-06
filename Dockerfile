FROM node:8-slim

# Install CoffeeScript, Hubot
RUN \
  npm install -g coffee-script hubot yeoman-doctor yo generator-hubot && \
  rm -rf /var/lib/apt/lists/*

# make user for bot
# yo requires uid/gid 501
RUN groupadd -g 501 hubot && \
  useradd -m -u 501 -g 501 hubot

COPY ["external-scripts.json","package.json","scripts/", "/home/hubot/bot/"]

# make directories and files
RUN mkdir -p /home/hubot/.config/configstore && \
  echo "optOut: true" > /home/hubot/.config/configstore/insight-yo.yml && \
  chown -R hubot:hubot /home/hubot

USER hubot
WORKDIR /home/hubot/bot

# optionally override variables with docker run -e HUBOT_...
# Modify ./ENV file to override these options
ENV HUBOT_OWNER hubot
ENV HUBOT_NAME hubot
ENV HUBOT_ADAPTER slack
ENV HUBOT_DESCRIPTION Just a friendly robot

RUN /usr/local/bin/yo hubot --help

RUN yes n | /usr/local/bin/yo hubot --adapter ${HUBOT_ADAPTER} --owner ${HUBOT_OWNER} --name ${HUBOT_NAME} --description ${HUBOT_DESCRIPTION} --defaults --no-insight; exit 0 && \
  npm audit fix && \
  npm install && \
  npm audit fix --force

# Override adapter with --env-file ENV
ENTRYPOINT bin/hubot
