# Snap's Linux build and the desktops axx runs its desktop features on (X11, and GNOME Shell on
# Wayland), in one image: run.sh builds Snap and its MCP server and runs the features. A run
# anywhere sees the same libraries, and draws the same pixels.
FROM ubuntu:24.04@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git rsync file xz-utils \
      dbus dbus-x11 dbus-user-session at-spi2-core fonts-dejavu-core \
      xvfb x11-utils \
      gnome-shell mutter pipewire wireplumber xwayland xdg-desktop-portal xdg-desktop-portal-gnome \
      eog scrot xdotool gnome-screenshot nautilus xdg-utils \
      build-essential pkg-config libwebkit2gtk-4.1-dev libxdo-dev libssl-dev librsvg2-dev \
      libayatana-appindicator3-dev \
      python3 python3-venv \
    && rm -rf /var/lib/apt/lists/*
# Node.js and Rust, pinned.
ARG NODE=22.23.3 RUST=1.99.0
RUN arch=$(dpkg --print-architecture | sed 's/amd64/x64/') \
    && curl -fsSL "https://nodejs.org/dist/v$NODE/node-v$NODE-linux-$arch.tar.xz" | tar -xJ -C /opt \
    && ln -s "/opt/node-v$NODE-linux-$arch/bin/"* /usr/local/bin/
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain "$RUST"
ENV PATH=/root/.cargo/bin:$PATH
# The backdrop's viewer shows the picture at its size on the full screen, not enlarged to fill it.
RUN printf '[org.gnome.eog.fullscreen]\nupscale=false\n' > /usr/share/glib-2.0/schemas/90_snap-acceptance.gschema.override \
    && glib-compile-schemas /usr/share/glib-2.0/schemas
# The container has no GPU: WebKitGTK's DMA-BUF renderer draws through software OpenGL there,
# and Snap's first frame took 4 seconds; without it, 0.3.
ENV WEBKIT_DISABLE_DMABUF_RENDERER=1
COPY run.sh /usr/local/bin/snap-acceptance
