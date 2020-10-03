# gcloud SDK supports up to python 3.7
FROM python:3.7-slim

ENV TERRAFORM_CIRCLECI_PLUGIN_VERSION=0.1.0
#ENV TERRAFORM_VERSION=0.13.0
#ENV ISTIO_VERSION=1.6.7
#ENV HELM_VERSION=3.2.4

ARG TERRAFORM_VERSION=0.12.29
ARG TERRAFORM_VERSION_SHA256SUM=872245d9c6302b24dc0d98a1e010aef1e4ef60865a2d1f60102c8ad03e9d5a1d
ARG TERRAFORM_VALIDATOR_RELEASE=2020-03-05

ENV ENV_TERRAFORM_VERSION=$TERRAFORM_VERSION
ENV ENV_TERRAFORM_VERSION_SHA256SUM=$TERRAFORM_VERSION_SHA256SUM
ENV ENV_TERRAFORM_VALIDATOR_RELEASE=$TERRAFORM_VALIDATOR_RELEASE


# Dependencies (~12MB)
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    unzip \
    && apt-get --purge -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# helm (~80MB)
#RUN curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
#    && tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
#    && cp ./linux-amd64/helm /usr/local/bin \
#    && rm helm-v${HELM_VERSION}-linux-amd64.tar.gz

# awscli (~100MB)
#RUN curl -LO https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
#    && unzip awscli-exe-linux-x86_64.zip \
#    && ./aws/install \
#    && rm -rf ./aws \
#    && rm awscli-exe-linux-x86_64.zip

# terraform (~70MB)
RUN curl -LO https://releases.hashicorp.com/terraform/${ENV_TERRAFORM_VERSION}/terraform_${ENV_TERRAFORM_VERSION}_linux_amd64.zip \
    && echo "${ENV_TERRAFORM_VERSION_SHA256SUM} terraform_${ENV_TERRAFORM_VERSION}_linux_amd64.zip" > terraform_SHA256SUMS \
    && sha256sum -c terraform_SHA256SUMS --status \
    && unzip terraform_${ENV_TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${ENV_TERRAFORM_VERSION}_linux_amd64.zip

# terraform circleci plugin (~14MB)
RUN curl -LO https://github.com/TomTucka/terraform-provider-circleci/releases/download/v${TERRAFORM_CIRCLECI_PLUGIN_VERSION}/terraform-provider-circleci_${TERRAFORM_CIRCLECI_PLUGIN_VERSION}_linux_amd64.zip \
    && mkdir -p $HOME/.terraform.d/plugins/linux_amd64 \
    && unzip terraform-provider-circleci_${TERRAFORM_CIRCLECI_PLUGIN_VERSION}_linux_amd64.zip \
    && mv terraform-provider-circleci_v${TERRAFORM_CIRCLECI_PLUGIN_VERSION} $HOME/.terraform.d/plugins/linux_amd64/ \
    && rm terraform-provider-circleci_${TERRAFORM_CIRCLECI_PLUGIN_VERSION}_linux_amd64.zip

# istio sources (~220MB)
#RUN curl -L https://istio.io/downloadIstio | sh - \
#    && mkdir -p $HOME/.istioctl/bin \
#    && cp istio-${ISTIO_VERSION}/bin/istioctl $HOME/.istioctl/bin/istioctl

# Pipenv (~39 MB)
RUN pip install --no-cache-dir --upgrade pip pipenv

COPY Pipfile.lock Pipfile ./

# Python dependencies (~219MB)
RUN pipenv install --dev --system --deploy --ignore-pipfile

# Not having a specific version for kubectl and google SDK we keep them at the bottom to get invalidated more often
# Google cloud SDK (~511MB)
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y \
        google-cloud-sdk \
    && apt-get --purge -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Terraform validator (~77MB)
RUN gsutil cp gs://terraform-validator/releases/${ENV_TERRAFORM_VALIDATOR_RELEASE}/terraform-validator-linux-amd64 /builder/terraform/terraform-validator \
    && chmod +x /builder/terraform/terraform-validator

# kubectl (~45MB)
#RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
#    && chmod +x ./kubectl \
#    && mv ./kubectl /usr/local/bin/kubectl

RUN mkdir -p /platform
WORKDIR /platform
#COPY . .
