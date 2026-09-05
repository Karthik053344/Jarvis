FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Xvfb, VNC, noVNC, window manager, terminal, and Supervisor
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    xfce4-terminal \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Configure Supervisor to run all graphical services headlessly
RUN bash -c 'cat <<EOF > /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1280x720x24
autostart=true
autorestart=true
priority=10

[program:fluxbox]
command=/usr/bin/fluxbox
environment=DISPLAY=":1"
autostart=true
autorestart=true
priority=15

[program:x11vnc]
command=/usr/bin/x11vnc -display :1 -nopw -forever -shared -rfbport 5900
autostart=true
autorestart=true
priority=20

[program:novnc]
command=/usr/bin/websockify --web /usr/share/novnc 8080 localhost:5900
autostart=true
autorestart=true
priority=25

[program:terminal]
command=/usr/bin/xfce4-terminal
environment=DISPLAY=":1"
autostart=true
autorestart=true
priority=30
EOF'

# Expose VNC port (5900) and noVNC web port (8080)
EXPOSE 5900 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]