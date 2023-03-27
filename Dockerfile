FROM ghcr.io/auguwu/coder-images/java

ENV USERNAME=noel

# go into root, we need to install some stuff (like Docker)
USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y && apt install -y postgresql-client redis-tools

# go back to noel user
USER ${USERNAME}

# Node.js
COPY --from=ghcr.io/auguwu/coder-images/node /opt/nodejs /opt/nodejs

# Go back to the user
USER ${USERNAME}

ENV LANG="en-US.UTF-8"
ENV PATH=$PATH:/opt/nodejs/bin
