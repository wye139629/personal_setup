FROM ubuntu:latest AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y software-properties-common curl git build-essential sudo && \
  apt-add-repository -y ppa:ansible/ansible && \
  apt-get update && \
  apt-get install -y curl git ansible build-essential && \
  apt-get clean autoclean && \
  apt-get autoremove --yes

FROM base AS setup_user
# Configure sudo for the william user
RUN echo "william ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN addgroup --gid 1000 william
RUN adduser --gecos william --uid 1000 --gid 1000 --disabled-password william 
RUN usermod -aG sudo william
USER william
WORKDIR /home/william

FROM setup_user

# Set up Homebrew and load environment settings within the same shell session
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/william/.bashrc

CMD ["sh", "-c", "source /home/linuxbrew/.linuxbrew/bin/brew && ansible-playbook $TAGS local.yml"]

COPY . ./my_setup
