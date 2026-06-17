FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG USERNAME=vscode
ARG RUBY_VERSION=4.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    build-essential \
    ca-certificates \
    curl \
    git \
    libdb-dev \
    libffi-dev \
    libgdbm-dev \
    libgmp-dev \
    libncurses-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libyaml-dev \
    pkg-config \
    rustc \
    uuid-dev \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://mise.run | sh \
  && install -m 0755 /root/.local/bin/mise /usr/local/bin/mise \
  && rm -rf /root/.local/bin/mise

ENV MISE_DATA_DIR=/usr/local/share/mise \
    MISE_CONFIG_DIR=/usr/local/etc/mise \
    MISE_CACHE_DIR=/usr/local/share/mise/cache \
    MISE_INSTALLS_DIR=/usr/local/share/mise/installs \
    MISE_SHIMS_DIR=/usr/local/share/mise/shims \
    PATH=/usr/local/share/mise/shims:/usr/local/bin:$PATH

RUN mkdir -p \
    "$MISE_DATA_DIR" \
    "$MISE_CONFIG_DIR" \
    "$MISE_CACHE_DIR" \
    "$MISE_INSTALLS_DIR" \
    "$MISE_SHIMS_DIR" \
  && chown -R "$USERNAME:$USERNAME" \
    "$MISE_DATA_DIR" \
    "$MISE_CONFIG_DIR" \
    "$MISE_CACHE_DIR" \
    "$MISE_INSTALLS_DIR" \
    "$MISE_SHIMS_DIR"

USER $USERNAME

RUN mise use --global ruby@$RUBY_VERSION \
  && mise install \
  && mise reshim ruby \
  && gem update --system \
  && gem install bundler

RUN echo 'eval "$(mise activate bash)"' >> "/home/$USERNAME/.bashrc" \
  && echo 'eval "$(mise activate zsh)"' >> "/home/$USERNAME/.zshrc"
