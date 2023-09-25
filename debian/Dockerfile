FROM debian:bookworm-slim

# Build args
ARG username
ARG password

# Environment variables
ENV USER=$username \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_CTYPE=en_US.UTF-8 \
    TERM=screen-256color \
    NIX_PATH=/root/.nix-defexpr/channels

# Update system and install dependencies
RUN apt-get update && apt-get install -y curl xz-utils sudo git zsh xdg-user-dirs
SHELL [ "/bin/zsh", "-c" ]
# Add a new user
RUN useradd -m ${username} && echo ${username}:${password} | chpasswd && usermod -aG sudo ${username}

# Install Nix
RUN mkdir -m 0755 /nix && chown ${USER} /nix
USER ${USER}
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
RUN mkdir -p /home/${USER}/.dev_env

# Copy flake.lock if exists, else let Nix generate the lock file inside the container
COPY flake.lock* /home/${USER}/.dev_env/
COPY flake.nix /home/${USER}/.dev_env/
WORKDIR /home/${USER}/.dev_env/

# Run nix to install tools and setup environment
# You will need to create default.nix which describes the environment (similar to the Dockerfile)
RUN mkdir -p /home/${USER}/.config/nix/
RUN echo "experimental-features = nix-command flakes" >> /home/${USER}/.config/nix/nix.conf
RUN echo ". /home/${USER}/.nix-profile/etc/profile.d/nix.sh" >> /home/${USER}/.zshrc

RUN . /home/${USER}/.nix-profile/etc/profile.d/nix.sh && \
    nix develop

WORKDIR /home/${USER}
RUN git clone https://github.com/jl178/dotfiles.git
RUN cd dotfiles && cp zsh/.zshrc /home/${USER}/ && cp -R ./ /home/${USER}/.config/
RUN echo "source /home/${USER}/.nix-profile/etc/profile.d/nix.sh" >> /home/${USER}/.zshrc
RUN mkdir -p /home/${USER}/.config/nix/
RUN echo "experimental-features = nix-command flakes" >> /home/${USER}/.config/nix/nix.conf

# Override the entrypoint to source the Nix environment script before running the command
WORKDIR /home/${USER}/.dev_env
ENTRYPOINT [ "bash", "-c", "source /home/${USER}/.nix-profile/etc/profile.d/nix.sh && exec \"$0\" \"$@\"", "nix", "--extra-experimental-features", "nix-command", "develop"]

# Provide the default arguments to ENTRYPOINT, including the --extra-experimental-features flag
