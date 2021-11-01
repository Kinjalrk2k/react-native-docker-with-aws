FROM public.ecr.aws/amazoncorretto/amazoncorretto:latest

LABEL MAINTAINER ANAM AHMED
LABEL VERSION 0.4
LABEL AUTHOR_EMAIL me@anam.co
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get -y install nodejs unzip

# ENV VARIABLES
ENV SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_VERSION=27 \
    ANDROID_BUILD_TOOLS_VERSION=28.0.3\
    GRADLE_VERSION=6.1.1\
    MAVEN_VERSION=3.6.3

WORKDIR ${ANDROID_HOME}

# GET SDK MANAGER
RUN curl -sL -o android.zip ${SDK_URL} && unzip android.zip && rm android.zip
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# ANDROID SDK AND PLATFORM
RUN $ANDROID_HOME/tools/bin/sdkmanager --update
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"

# GRADLE
RUN curl -sL -o gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip &&\
 mkdir /opt/gradle && unzip -d /opt/gradle gradle.zip && rm gradle.zip

# ADD PATH TO BASHRC
RUN export PATH=$PATH:$ANDROID_HOME/emulator\
    && export PATH=$PATH:$ANDROID_HOME/tools\
    && export PATH=$PATH:$ANDROID_HOME/tools/bin\
    && export PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin\
    && export PATH=$PATH:/opt/maven/apache-maven-${MAVEN_VERSION}/bin\
    && echo PATH=$PATH:$ANDROID_HOME/platform-tools>>/etc/bash.bashrc

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-setuptools \
        groff \
        less \
    && pip3 install --upgrade pip \
    && apt-get clean

RUN pip3 --no-cache-dir install --upgrade awscli