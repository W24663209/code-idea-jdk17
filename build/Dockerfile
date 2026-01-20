FROM codercom/enterprise-base:ubuntu

USER root
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && chmod a+r /etc/apt/keyrings/docker.gpg \
  && . /etc/os-release \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    maven \
    openjdk-11-jdk \
    ca-certificates \
    curl \
    sudo \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-ce-rootless-extras \
    uidmap \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN usermod -aG docker coder
RUN echo "coder:100000:65536" >> /etc/subuid \
  && echo "coder:100000:65536" >> /etc/subgid

USER coder
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
