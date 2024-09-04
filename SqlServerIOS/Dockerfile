FROM mcr.microsoft.com/mssql/server:2017-latest

# ----------------------------------------------------------------
# INSTALLs
# ----------------------------------------------------------------
RUN \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y -q apt-utils \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata \
    && apt-get install -y net-tools \
    && apt-get install -y iputils-ping \
    && apt-get install -y openssh-server \
    && apt-get install -y nano \
    && apt-get install -y sudo \
    && apt-get install -y cron \
    && apt-get clean

# ----------------------------------------------------------------
# COPYs
# ----------------------------------------------------------------
COPY ssh_init/ssh* /etc/ssh/
COPY docker_init/ /opt/docker_dependencies/

ARG USER
ARG PASSWORD

RUN useradd -m -d /home/${USER} -s /bin/bash ${USER}
RUN echo "${USER}:${PASSWORD}}" | chpasswd
RUN usermod -aG sudo ${USER}

# ----------------------------------------------------------------
# RUNs
# ----------------------------------------------------------------
ENV TZ=America/Monterrey
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
