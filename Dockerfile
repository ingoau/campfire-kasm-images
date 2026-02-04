FROM kasmweb/core-ubuntu-noble:1.17.0
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
    rm -f /tmp/gamemaker.deb; \

    # Install shiftkey/github desktop
    RUN wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
RUN sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'
RUN sudo apt update && sudo apt install github-desktop -y

RUN touch $HOME/Desktop/hello.txt


######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
