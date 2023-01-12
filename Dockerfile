FROM ghcr.io/auguwu/coder-images/java

ENV USERNAME=noel

# go into root, we need to install some stuff (like Docker)
USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y && apt install -y postgresql-client redis-tools

# go back to noel user
USER ${USERNAME}

# Add the Go toolchain here so we can develop the ClickHouse Migrations code
COPY --from=ghcr.io/auguwu/coder-images/golang /opt/golang/tools/golangci /opt/golang/tools/golangci
COPY --from=ghcr.io/auguwu/coder-images/golang /opt/golang/go             /opt/golang/go

# Add the Rust toochain so we can develop the Helm Plugin
COPY --from=ghcr.io/auguwu/coder-images/rust --chown=${USERNAME}:${USERNAME} /home/${USERNAME}/.rustup /home/${USERNAME}/.rustup
COPY --from=ghcr.io/auguwu/coder-images/rust --chown=${USERNAME}:${USERNAME} /home/${USERNAME}/.cargo  /home/${USERNAME}/.cargo

# node
COPY --from=ghcr.io/auguwu/coder-images/node /opt/nodejs /opt/nodejs

# Go back to the user
USER ${USERNAME}

ENV LANG="en-US.UTF-8"
ENV PATH=$PATH:/opt/golang/go/bin:/opt/golang/tools/golangci:/opt/nodejs/bin:/home/${USERNAME}/.cargo/bin
