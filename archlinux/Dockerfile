FROM archlinux:base-devel

# Build args
ARG username
ARG password

# Environment variables
ENV USER=$username \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    NODE_VERSION=18 \
    PYTHON_VERSION=3.9.6 \
    SHELL=/bin/zsh \
    TERRAFORM_VERSION=1.3.6 \
    LC_CTYPE=en_US.UTF-8 \
    TERM=screen-256color

# Update system and install dependencies
RUN pacman -Syu --noconfirm 

# Add a new user
RUN useradd -m ${username} && echo ${username}:${password} | chpasswd && usermod -aG wheel ${username}

# Allow wheel group to have sudo access
RUN echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo

# Set timestamp timeout
RUN echo 'Defaults timestamp_timeout=15' | EDITOR='tee -a' visudo

# AUR packages
RUN pacman -S --noconfirm git
RUN pacman -S --noconfirm curl
RUN pacman -S --noconfirm zsh
RUN pacman -S --noconfirm sudo
RUN pacman -S --noconfirm jdk11-openjdk
RUN pacman -S --noconfirm ripgrep
RUN pacman -S --noconfirm lazygit 
RUN pacman -S --noconfirm pyenv
RUN pacman -S --noconfirm xdg-user-dirs
RUN pacman -S --noconfirm lsd
RUN pacman -S --noconfirm fzf
RUN pacman -S --noconfirm ranger
RUN pacman -S --noconfirm neovim
RUN pacman -S --noconfirm unzip
RUN pacman -S --noconfirm docker
RUN pacman -S --noconfirm github-cli
RUN pacman -S --noconfirm htop
RUN pacman -S --noconfirm k9s
RUN pacman -S --noconfirm go

# Set zsh as default shell
RUN chsh -s /bin/zsh

# terraform (via tfenv)
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git /home/${username}/.tfenv
RUN ln -s /home/${username}/.tfenv/bin/* /usr/local/bin
RUN tfenv install $TERRAFORM_VERSION
RUN tfenv use $TERRAFORM_VERSION

# AWS CLI
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    fi
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -rf awscliv2 && rm awscliv2.zip

# Kubectl
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"; \
    fi
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Kind
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-arm64; \
    fi
RUN chmod +x ./kind
RUN mv ./kind /usr/local/bin/kind

# Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Docker config
RUN usermod -aG docker $USER

# Switch to the new user
USER ${USER}
WORKDIR /home/${USER}

# dotfiles
RUN git clone https://github.com/jl178/dotfiles.git
RUN cd dotfiles && echo -e "y" | ./install.sh
RUN rm -rf dotfiles

# Change default shell for all future commands
SHELL [ "/bin/zsh", "-c" ]
ENV SHELL=/bin/zsh

## nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> ~/.zshrc 
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.zshrc

## node install
RUN source ~/.zshrc && nvm install $NODE_VERSION

## python install
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc 
RUN echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc 
RUN echo 'eval "$(pyenv init -)"' >> ~/.zshrc

RUN source ~/.zshrc && pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION && pyenv install 3.7.10

# java version switcher (via jenv)
RUN git clone https://github.com/jenv/jenv.git ~/.jenv
RUN echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(jenv init -)"' >> ~/.bash_profile 
RUN echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
RUN echo 'eval "$(jenv init -)"' >> ~/.zshrc
RUN source ~/.zshrc && jenv enable-plugin export

# GCloud CLI
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-437.0.1-linux-x86_64.tar.gz; \
    tar -xf google-cloud-sdk-437.0.1-linux-x86_64.tar.gz; \
    ./google-cloud-sdk/install.sh; \
    rm google-cloud-cli-437.0.1-linux-x86_64.tar.gz; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-437.0.1-linux-arm.tar.gz; \
    tar -xf google-cloud-sdk-437.0.1-linux-arm.tar.gz; \
    ./google-cloud-sdk/install.sh; \
    rm google-cloud-cli-437.0.1-linux-arm.tar.gz; \
    fi


# Aliases
## Anything needing Docker access (host) needs sudo
RUN echo 'alias docker="sudo docker"' >> ~/.zshrc
RUN echo 'alias helm="sudo helm"' >> ~/.zshrc
RUN echo 'alias kubectl="sudo kubectl"' >> ~/.zshrc
RUN echo 'alias kind="sudo kind"' >> ~/.zshrc

# Git configs
RUN git config --global --add safe.directory '*'

# Set the default command to zsh
CMD [ "/bin/zsh" ]

