FROM debian:bookworm-20231030-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6OVERLAY_VERSION="v3.1.5.0"

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
    # chrony dependencies
    TEMP_PACKAGES+=(asciidoctor) && \
    TEMP_PACKAGES+=(bison) && \
    # gpsd dependencies
    TEMP_PACKAGES+=(libncurses5-dev) && \
    TEMP_PACKAGES+=(pkg-config) && \
    KEPT_PACKAGES+=(pps-tools) && \
    TEMP_PACKAGES+=(python3-distutils) && \
    KEPT_PACKAGES+=(python3-serial) && \
    TEMP_PACKAGES+=(scons) && \
    # convenience
    KEPT_PACKAGES+=(nano) && \
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
    curl --location --output /tmp/deploy-s6-overlay.sh https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay-v3.sh && \
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
    # fix healthchecks framework pathing
    sed -i 's/S6_SERVICE_PATH="\/run\/s6\/services"/S6_SERVICE_PATH="\/run\/s6\/legacy-services"/g' /opt/healthchecks-framework/checks/check_s6_service_abnormal_death_tally.sh && \
    # Add s6wrap
    pushd /tmp && \
      git clone --depth=1 https://github.com/wiedehopf/s6wrap.git && \
      cd s6wrap && \
      make && \
      mv s6wrap /usr/local/bin && \
    popd && \
    # Add additional stuff
    mkdir -p /scripts /etc/cont-init.d && \
    curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/install_libseccomp2.sh | bash && \
    chmod +x /etc/s6-overlay/s6-rc.d/libseccomp2/up && \
    chmod +x /etc/s6-overlay/scripts/libseccomp2_check.sh && \
    curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/docker-baseimage/main/scripts/common -o /scripts/common && \
    # deploy chrony
    pushd /tmp && \
    git clone --depth=1 https://gitlab.com/chrony/chrony.git && \
      cd chrony && \
      echo $(git rev-list -n 1 HEAD | cut -c 1-7) > version.txt && \
      ./configure --prefix=/usr --enable-scfilter --with-ntp-era=$(date +'%s') && \
      make -j $(nproc) && \
      make install && \
    popd && \
    # deploy gpsd
    pushd /tmp && \
    git clone --depth=1 https://gitlab.com/gpsd/gpsd.git && \
      cd gpsd && \
      scons -c && \
      scons -j $(nproc) timeservice=yes python=true ublox=yes manbuild=No shm_export=true prefix=/usr python_libdir=/usr/lib/python3/dist-packages && \
      scons install && \
    popd && \
    # Add Container Version
    branch="##BRANCH##" && \
    [[ "${branch:0:1}" == "#" ]] && branch="master" || true && \
    git clone --depth=1 -b $branch https://github.com/ifb/docker-clock.git /tmp/clone && \
    pushd /tmp/clone && \
    echo "$(TZ=UTC date +%Y%m%d-%H%M%S)_$(git rev-parse --short HEAD)_$(git branch --show-current)" > /.CONTAINER_VERSION && \
    popd && \
    rm -rf /tmp/* && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/*

COPY rootfs/ /

ENTRYPOINT [ "/init" ]
