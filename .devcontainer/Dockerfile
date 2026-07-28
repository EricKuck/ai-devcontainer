FROM ubuntu:24.04

ARG USERNAME=eric
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    gnupg \
    jq \
    unzip \
    zip \
    tar \
    build-essential \
    cmake \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    openssh-client \
    iputils-ping \
    tmux \
    vim \
    ripgrep \
    fd-find \
    fzf \
    less \
    tree \
    file \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/fdfind /usr/local/bin/fd

# install node
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# install github cli
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# take over UID/GID 1000 from the default ubuntu user
RUN set -eux; \
    if getent passwd "${USER_UID}" | grep -q '^ubuntu:'; then userdel --remove ubuntu; fi; \
    if getent group "${USER_GID}" | grep -q '^ubuntu:'; then groupdel ubuntu; fi; \
    groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# install harnesses
RUN npm install -g \
    @anthropic-ai/claude-code \
    opencode-ai \
    @openai/codex \
    @github/copilot \
    @earendil-works/pi-coding-agent

# install rtk
RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh \
    | RTK_INSTALL_DIR=/usr/local/bin sh \
    && rtk --version

ENV DEBIAN_FRONTEND=dialog

USER ${USERNAME}
WORKDIR /home/${USERNAME}
