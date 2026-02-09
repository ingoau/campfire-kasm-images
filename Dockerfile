FROM kasmweb/core-debian-trixie:1.18.0-rolling-weekly
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y iputils-ping git

# Install gamemaker
RUN set -eux; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    curl -fL --retry 5 --retry-delay 2 \
    "https://gamemaker.io/en/download/ubuntu/beta/GameMaker.zip" \
    -o /tmp/gamemaker.deb; \
    dpkg-deb -I /tmp/gamemaker.deb >/dev/null; \
    apt-get update; \
    apt-get install -y /tmp/gamemaker.deb; \
    rm -f /tmp/gamemaker.deb;

# Install shiftkey/github desktop
RUN wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null

RUN wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/mwt-desktop.gpg > /dev/null
RUN sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list'
RUN sudo apt update && sudo apt install github-desktop -y

# Allow kasm-user to use sudo without password
RUN echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000

# Install proot-apps
RUN rm -f $HOME/.local/bin/{ncat,proot-apps,proot,jq} && \
    mkdir -p $HOME/.local/bin && \
    curl -L https://github.com/linuxserver/proot-apps/releases/download/$(curl -sX GET "https://api.github.com/repos/linuxserver/proot-apps/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')/proot-apps-$(uname -m).tar.gz | tar -xzf - -C $HOME/.local/bin/

ENV PATH="$HOME/.local/bin:$PATH"
RUN proot-apps install gui
