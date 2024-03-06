FROM python:3.6

# Copy the Chrome executable to the image
#RUN unzip ./chrome/chrome.deb.zip
#COPY ./chrome/chrome.deb /chrome.deb

# # Install chrome stable for UI tests
# RUN apt-get update && apt-get install gnupg wget -y && \
#     wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
#     sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
#     apt-get update && \
#     apt-get install /chrome.deb -y --no-install-recommends && \
#     rm -rf /var/lib/apt/lists/*
#
# # Install Chromedriver
# COPY ./chrome/chromedriver /usr/bin/chromedriver
# RUN chmod a+x /usr/bin/chromedriver

# Install necessary tools
RUN apt-get update && apt-get install -y gnupg wget

# Install Chrome
# ENV CHROME_VERSION=120.0.6099.109-1
# RUN wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb
# RUN apt-get -y update
# RUN apt-get install -y ./google-chrome-stable_${CHROME_VERSION}_amd64.deb
#
# # Clean up
# RUN apt-get clean && \
#     rm -rf /var/lib/apt/lists/*
#
# # Install Chromedriver
# RUN wget -q --continue -P /chromedriver "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/120.0.6099.109/linux64/chromedriver-linux64.zip" && \
#     unzip /chromedriver/chromedriver* -d /usr/local/bin/
#
# #ENV PATH="${PATH}:/usr/local/bin/chromedriver-linux64/"
# ENV PATH /usr/local/bin/chromedriver-linux64:$PATH
# # COPY ./chrome/chromedriver /usr/bin/chromedriver
# #RUN chmod a+x /usr/local/bin/chromedriver-linux64/chromedriver
# RUN chmod 755 /usr/local/bin/chromedriver-linux64/chromedriver

#Install Firefox

ENV FIREFOXBROWSER_VERSION 122.0

# RUN wget https://ftp.mozilla.org/pub/firefox/releases/$FIREFOXBROWSER_VERSION/linux-x86_64/en-US/firefox-$FIREFOXBROWSER_VERSION.tar.bz2 \
#    && tar -xjf "firefox-$FIREFOXBROWSER_VERSION.tar.bz2" \
#    && mv firefox /opt/firefox \
#    && ln -s /opt/firefox/firefox /usr/bin/firefox-browser \
#    && ln -s /usr/bin/headless-firefox /usr/bin/firefox \
#    && rm "firefox-$FIREFOXBROWSER_VERSION.tar.bz2"

RUN apt-get install -y firefox-esr

# Download and install GeckoDriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz \
    && tar -xvzf geckodriver-v0.33.0-linux64.tar.gz \
    && mv geckodriver /usr/local/bin/

ENV PATH /usr/local/bin/:$PATH

RUN chmod 755 /usr/local/bin/geckodriver

WORKDIR /qatest
COPY ./Tests/ ./functionalTest
COPY requirements.txt ./requirements.txt

RUN python -m pip install --upgrade pip
RUN pip install --trusted-host pypi.python.org --trusted-host pypi.org --trusted-host=files.pythonhosted.org --trusted-host edgedl.me.gvt1.com -r ./requirements.txt
RUN rm ./requirements.txt

RUN groupadd -g 1000 jenkins \
  && useradd -ms /bin/bash -r -u 1000 -g jenkins jenkins

RUN chown -R jenkins:jenkins \
    /qatest

USER jenkins

#CMD ["python", "-m","robot", "-d", "/reports", "-x", "junit-report.xml", "/qatest/functionalTest/"]
CMD robot -d /reports /qatest/functionalTest/
#CMD ["python", "-m", "robot", "-d", "/reports", "/qatest/functionalTest/", "&&", "rebot", "--output", "/reports/output.json /reports/output.xml"]
#CMD ["sh", "-c", "python -m robot -d /reports /qatest/functionalTest/ && python -m robot.rebot --output /reports/output.json "]

