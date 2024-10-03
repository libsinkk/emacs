FROM fedora:33

RUN dnf upgrade --assumeyes && \
    dnf install --assumeyes emacs make
