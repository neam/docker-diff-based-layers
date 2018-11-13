FROM fedora:28
RUN dnf update -y
RUN dnf install -y gettext-devel intltool
