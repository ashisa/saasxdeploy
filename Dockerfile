ARG PYTHON_VERSION="3.6.10"

FROM python:${PYTHON_VERSION}-slim-buster

# Installing prerequites
RUN chmod ugo+rwXt /tmp \
  && apt-get update \
  && apt-get install apt-utils \
  && apt-get install ca-certificates curl apt-transport-https lsb-release gnupg vim wget git -y

# Installing Azure CLI; use azure-cli=version to target specific version
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update \
  && apt-get install azure-cli \
  && az aks install-cli --install-location /usr/bin/kubectl

# Downloading GoTTY and copying it to /usr/bin
RUN curl -L https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz | tar zx -C /usr/bin/

# Installing PowerShell Core prerequisites
RUN curl -L https://github.com/unicode-org/icu/releases/download/release-66-1/icu4c-66_1-Ubuntu18.04-x64.tgz | tar xz -C /tmp \
  && cp -R /tmp/icu/* / && cp -R /tmp/icu/usr/local/lib/* /usr/lib/ && rm -fr /tmp/icu

# Installing PowerShell Core 7
RUN mkdir -p /opt/microsoft/powershell/7 \
  && curl -L https://github.com/PowerShell/PowerShell/releases/download/v6.2.4/powershell-6.2.4-linux-x64.tar.gz \
  | tar xz -C /opt/microsoft/powershell/7 \
  && chmod a+x /opt/microsoft/powershell/7/pwsh \
  && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Installing Az module
RUN pwsh -c install-module -Force Az
RUN pwsh -c install-module -Force AzureAD

# Setting up repos to install dotnet core using apt
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg \
  && mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ \
  && wget -q https://packages.microsoft.com/config/debian/10/prod.list \
  && mv prod.list /etc/apt/sources.list.d/microsoft-prod.list \
  && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg \
  && chown root:root /etc/apt/sources.list.d/microsoft-prod.list

# Installing dotnet core
RUN chmod ugo+rwXt /tmp \
  && apt-get update \
  && apt-get install apt-transport-https -y \
  && apt-get update \
  && apt-get install dotnet-sdk-6.0 -y

EXPOSE 8080
CMD [ "/bin/bash" ]
