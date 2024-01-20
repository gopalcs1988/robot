FROM python:3

# Copy the Chrome executable to the image
COPY ./chrome/chrome.deb /chrome.deb

# Install chrome stable for UI tests
RUN apt-get update && apt-get install gnupg wget -y && \
    wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install /chrome.deb -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Install Chromedriver
COPY ./chrome/chromedriver /usr/bin/chromedriver
RUN chmod a+x /usr/bin/chromedriver

# FROM python:3
#
# # Install necessary tools
# RUN apt-get update && apt-get install -y gnupg wget
#
# # Install Chrome
# RUN wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
#     echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
#     apt-get update && \
#     apt-get install -y google-chrome-stable --no-install-recommends && \
#     rm -rf /var/lib/apt/lists/*
#
# # Install Chromedriver
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# RUN wget --quiet -O /usr/bin/chromedriver https://chromedriver.storage.googleapis.com/$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver && \
#     chmod +x /usr/bin/chromedriver


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

CMD ["python", "-m", "robot", "-d", "reports", "-x", "junit-report.xml", "/qatest/functionalTest/"]