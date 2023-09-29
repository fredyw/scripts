FROM ubuntu

ARG USERNAME=fredyw
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd --gid $USER_GID ${USERNAME} \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash ${USERNAME} \
    && apt-get update \
    && apt-get install -y sudo build-essential git \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} .ssh .ssh
RUN git clone git@github.com:fredyw/scripts /home/${USERNAME}/github/scripts