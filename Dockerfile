FROM ubuntu:latest AS build
ARG DPAVERSION
ENV DPAVERSION=${DPAVERSION}

WORKDIR /tmp/app

# Initial update and basic utilities for downloading files
RUN apt update -y
RUN apt install curl -y

# Download DPA archive and signature along with static SolarWinds key
RUN echo LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0gCk1JR2JNQkFHQnlxR1NNNDlBZ0VHQlN1QkJBQWpBNEdHQUFRQnd6RGxkSGQzczU0OG9nd2NDVlRSRjJXWGNmSmoKQklmRWx2RHpYKzV6akRnaHhDSnpGTzRwWFNNdFVGb0IyZkQyQkdqVmdkY1pSRFJhY3J2LzlHUzUyZmNCVjlzWQpxUmprUVZWenNvZEQwMlFva0RUblRMT0FpZzRMTXZuRUpXTzFGOFVHTTVnYmlhWHR1VU5NRk5FRkVsQ04zRkg2CmE4ZVQ0UVJWNVhvS05aejNtbzQ9Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo= | base64 --decode > solarwinds.pem
RUN curl -LO https://downloads.solarwinds.com/solarwinds/Release/DPA/${DPAVERSION}/SolarWinds-DPA-${DPAVERSION}-64bit.tar.gz
RUN curl -LO https://downloads.solarwinds.com/solarwinds/Release/DPA/${DPAVERSION}/SolarWinds-DPA-${DPAVERSION}-64bit.tar.gz.sig

# install utilities for verifying signatures and interact with install script
RUN apt install openssl -y
RUN apt install expect -y
RUN apt install fontconfig -y
RUN apt install rename -y

# Verify the signatures using SHA512 and Solarwinds public key
RUN openssl dgst -sha512 -keyform PEM -verify /tmp/app/solarwinds.pem -signature /tmp/app/SolarWinds-DPA-${DPAVERSION}-64bit.tar.gz.sig /tmp/app/SolarWinds-DPA-${DPAVERSION}-64bit.tar.gz || exit 1
RUN mkdir /app
RUN tar zxf /tmp/app/SolarWinds-DPA-${DPAVERSION}-64bit.tar.gz -C /app

# Move to production
WORKDIR /app

# Rename the extracted directory and shell script
RUN mv ./dpa* ./install
RUN mv ./install/*.sh ./install/dpa_install.sh

# Run the expect script to go through the install process
COPY install.expect .
RUN expect ./install.expect || exit 1

# Installation is complete at this point

# Remove the install files, no longer needed
RUN rm -rf /app/install
RUN rm -rf /tmp/app

# The script will target the installation in /app
# the final install location should be /app/dpa
VOLUME ["/app/dpa"]
EXPOSE 8124

# install rsync to copy over the default install
RUN apt install rsync -y

# Copy the entrypoint stat script
COPY start.sh ./
ENTRYPOINT [ "/app/start.sh" ]