FROM ubuntu:24.04

ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    xz-utils \
    unzip \
    git \
    ca-certificates \
    openjdk-17-jdk-headless \
    file \
    procps \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    curl -fsSL -o /tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-tmp && \
    mv /tmp/cmdline-tools-tmp/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}

RUN yes | sdkmanager --licenses > /dev/null && \
    sdkmanager "platforms;android-36" "build-tools;36.0.0" "ndk;28.2.13676358" "platform-tools" "cmake;3.22.1" && \
    rm -rf ${ANDROID_HOME}/.temp ${ANDROID_HOME}/cmdline-tools/latest/lib/.tmp

ARG FLUTTER_VERSION=3.47.1
RUN curl -fsSL -o /tmp/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar -xJf /tmp/flutter.tar.xz -C /opt && \
    rm /tmp/flutter.tar.xz && \
    flutter precache --android --universal 2>/dev/null || true

ENV PUB_CACHE=/opt/flutter/.pub-cache
ENV PATH=/opt/flutter/bin:/opt/flutter/.pub-cache/bin:${PATH}

RUN mkdir -p /workdir && \
    userdel -r ubuntu 2>/dev/null || true && \
    groupadd -g ${GID} dev 2>/dev/null || true && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash dev && \
    chown -R ${UID}:${GID} ${ANDROID_HOME} /opt/flutter /workdir

USER dev

RUN mkdir -p ${PUB_CACHE}/_temp && \
    flutter --version || true && \
    flutter config --no-analytics || true && \
    dart --disable-analytics || true

WORKDIR /workdir

CMD ["bash"]
