FROM ubuntu:24.04

ARG USERNAME=eric
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG ANDROID_COMPILE_SDK=35
ARG ANDROID_BUILD_TOOLS=35.0.0
ARG ANDROID_COMMANDLINE_TOOLS=11076708

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/opt/java
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${JAVA_HOME}/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    curl \
    ca-certificates \
    gnupg \
    jq \
    unzip \
    zip \
    tar \
    build-essential \
    cmake \
    openjdk-17-jdk-headless \
    openjdk-21-jdk-headless \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    openssh-client \
    iputils-ping \
    vim \
    ripgrep \
    fd-find \
    fzf \
    less \
    locales \
    tree \
    file \
    ncurses-term \
    sudo \
    imagemagick \
    webp \
    ffmpeg \
    tzdata \
    && ln -s "$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")" /opt/java \
    && rm -rf /var/lib/apt/lists/*

ARG TZ=America/New_York
RUN locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 \
    && ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime \
    && echo "${TZ}" > /etc/timezone

# initialize git-lfs
RUN git lfs install --system

RUN ln -s /usr/bin/fdfind /usr/local/bin/fd

# Install the Android SDK required by Android Gradle Plugin builds. The SDK is
# image-owned and immutable at runtime; update the build args to preinstall a
# different compile SDK or build-tools version.
RUN mkdir -p "${ANDROID_HOME}/cmdline-tools" \
    && curl -fsSLo /tmp/android-commandline-tools.zip \
        "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMANDLINE_TOOLS}_latest.zip" \
    && unzip -q /tmp/android-commandline-tools.zip -d /tmp/android-commandline-tools \
    && mv /tmp/android-commandline-tools/cmdline-tools "${ANDROID_HOME}/cmdline-tools/latest" \
    && rm -rf /tmp/android-commandline-tools /tmp/android-commandline-tools.zip \
    && yes | "${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" --sdk_root="${ANDROID_HOME}" --licenses \
    && "${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" --sdk_root="${ANDROID_HOME}" \
        "platform-tools" \
        "platforms;android-${ANDROID_COMPILE_SDK}" \
        "build-tools;${ANDROID_BUILD_TOOLS}" \
    && rm -rf "${ANDROID_HOME}/.android" \
    && chmod -R a+rX "${ANDROID_HOME}"

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

# install Ghostty terminfo so TERM=xterm-ghostty is recognized over SSH
COPY ghostty.terminfo /tmp/ghostty.terminfo
RUN tic -x /tmp/ghostty.terminfo && rm /tmp/ghostty.terminfo

# preserve TERM and TERMINFO through sudo so programs run under sudo
# (e.g. sudo vim) still recognise xterm-ghostty
RUN printf '%s\n' \
    'Defaults env_keep += "TERM"' \
    'Defaults env_keep += "TERMINFO"' \
    >> /etc/sudoers.d/10-ghostty && chmod 440 /etc/sudoers.d/10-ghostty

ENV DEBIAN_FRONTEND=dialog \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=${TZ}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
