FROM node:10.13.0

LABEL maintainer="Ajay Navulla"

ENV http_proxy=http://PROXY_DOMAIN:3128
ENV https_proxy=http://PROXY_DOMAIN:3128
ENV no_proxy="127.0.0.1,localhost,0.0.0.0,local_host"
ENV CHROME_BIN="/usr/bin/chromium-browser" \
    CHROME_PATH="/usr/bin/google-chrome" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"


RUN npm config set proxy "http://'<username>':'<password>'@PROXY_DOMAIN:3128/"
RUN npm config set https-proxy "http://'<username>':'<password>'@PROXY_DOMAIN:3128/"
RUN npm config set unsafe-perm=true
RUN npm config set strict-ssl false


RUN apt-get update

# install manually all the missing libraries
RUN apt-get install -y gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils libappindicator3-1

# install chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

RUN apt-get install -y apt-utils && \
    apt-get install -y bash && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y curl && \
    apt-get install -y udev && \
    apt-get install -y ttf-freefont && \
    apt-get install -y chromium && \
    apt-get install -y docker && \
    apt-get install -y unzip && \
    apt-get install -y time

RUN npm cache clean --force

RUN npm install -g @angular/cli@7.0.6
RUN npm install -g nodemon
RUN npm install -g forever
RUN npm install -g node-sass
RUN npm install -g puppeteer

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Create app directory
WORKDIR /usr/src/app

RUN curl --insecure -o ./sonarscanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.1.0.1141-linux.zip && \
    unzip sonarscanner.zip && \
    rm sonarscanner.zip && \
    mv sonar-scanner-3.1.0.1141-linux /usr/lib/sonar-scanner && \
    ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner && \
    chmod a+x /usr/local/bin/sonar-scanner

ENV SONAR_RUNNER_HOME=/usr/lib/sonar-scanner

#  Using default Java
RUN sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /usr/lib/sonar-scanner/bin/sonar-scanner

ENTRYPOINT ["/bin/bash", "-c"]
