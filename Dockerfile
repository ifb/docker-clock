FROM debian:bullseye-20230703-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6OVERLAY_VERSION=v2.2.0.3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,SC2086
RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # packages needed to install
    TEMP_PACKAGES+=(git) && \
    # logging
    KEPT_PACKAGES+=(gawk) && \
    KEPT_PACKAGES+=(pv) && \
    # required for S6 overlay
    # curl kept for healthcheck
    TEMP_PACKAGES+=(file) && \
    KEPT_PACKAGES+=(curl) && \
    TEMP_PACKAGES+=(xz-utils) && \
    KEPT_PACKAGES+=(ca-certificates) && \
    # bc for scripts and healthchecks
    KEPT_PACKAGES+=(bc) && \
    # packages for network stuff
    KEPT_PACKAGES+=(socat) && \
    KEPT_PACKAGES+=(ncat) && \
    KEPT_PACKAGES+=(net-tools) && \
    KEPT_PACKAGES+=(wget) && \
    # process management
    KEPT_PACKAGES+=(procps) && \
    # needed to compile s6wrap:
    TEMP_PACKAGES+=(gcc) && \
    TEMP_PACKAGES+=(build-essential) && \
    # install packages
    ## Builder fixes...
    mkdir -p /usr/sbin/ && \
    ln -s /usr/bin/dpkg-split /usr/sbin/dpkg-split && \
    ln -s /usr/bin/dpkg-deb /usr/sbin/dpkg-deb && \
    ln -s /bin/tar /usr/sbin/tar && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "${KEPT_PACKAGES[@]}" \
        "${TEMP_PACKAGES[@]}" \
        && \
    # install S6 Overlay
    curl --location --output /tmp/deploy-s6-overlay.sh https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh && \
    sh /tmp/deploy-s6-overlay.sh && \
    rm -f /tmp/deploy-s6-overlay.sh && \
    # deploy healthchecks framework
    git clone \
      --depth=1 \
      https://github.com/mikenye/docker-healthchecks-framework.git \
      /opt/healthchecks-framework \
      && \
    rm -rf \
      /opt/healthchecks-framework/.git* \
      /opt/healthchecks-framework/*.md \
      /opt/healthchecks-framework/tests \
      && \
    # Add s6wrap
    pushd /tmp && \
      git clone --depth=1 https://github.com/wiedehopf/s6wrap.git && \
      cd s6wrap && \
      make && \
      mv s6wrap /usr/local/bin && \
    popd && \
    # Add additional stuff
    mkdir -p /scripts /etc/cont-init.d && \
    curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/00-libseccomp2 -o /etc/cont-init.d/00-libsecomp2 && \
    curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/docker-baseimage/main/scripts/common -o /scripts/common && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/*

# ADD https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/00-libseccomp2 /etc/cont-init.d/00-libsecomp2

ENTRYPOINT [ "/init" ]

