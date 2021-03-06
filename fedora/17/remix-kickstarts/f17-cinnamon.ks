## f17-cinnamon.ks

%include f17-common.ks

part / --size 4096

%packages

# Unwanted stuff
-abrt*
-at-*
-caribou*
-deja-dup*
-gnome-games*
-orca*

### Cinnamon desktop
metacity
gnome-shell
cinnamon

### @gnome-desktop defaults 
control-center
notification-daemon
NetworkManager-gnome 
PackageKit-gtk*
avahi    
brasero-nautilus
cheese
eog
evince-nautilus
file-roller-nautilus
gcalctool
gdm
gedit
gnome-backgrounds
gnome-bluetooth
gnome-color-manager
gnome-disk-utility
gnome-media
gnome-packagekit
gnome-power-manager
gnome-screensaver
gnome-screenshot
gnome-search-tool
gnome-system-monitor
gnome-terminal
gnome-user-docs
gucharmap
gvfs-archive
gvfs-fuse
gvfs-gphoto2
gvfs-smb
ibus
libgnomeui
libproxy-mozjs
libsane-hpaio
mousetweaks
nautilus-sendto
policycoreutils-restorecond
pulseaudio-module-gconf
pulseaudio-module-x11
sane-backends-drivers-scanners
seahorse
shotwell                 
simple-scan
sushi
vinagre
vino
xdg-user-dirs-gtk
yelp

### @graphical-internet
firefox
icedtea-web
pidgin
thunderbird  
transmission-gtk

### @sound-and-video
alsa-plugins-pulseaudio
pavucontrol
rhythmbox
totem-mozplugin
totem-nautilus

### Multimedia
# ffmpegthumbnailer
gnash-plugin

### Office
libreoffice
libreoffice-langpack-it

### Tools
gparted

# FIXME; apparently the glibc maintainers dislike this, but it got put into the
# desktop image at some point.  We won't touch this one for now.
nss-mdns

# This one needs to be kicked out of @base
-smartmontools

%end

%post
cat >> /etc/rc.d/init.d/livesys << EOF
# disable screensaver locking
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.override << FOE
[org.gnome.desktop.screensaver]
lock-enabled=false
FOE

# and hide the lock screen option
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.lockdown.gschema.override << FOE
[org.gnome.desktop.lockdown]
disable-lock-screen=true
FOE

# disable updates plugin
cat >> /usr/share/glib-2.0/schemas/org.gnome.settings-daemon.plugins.updates.gschema.override << FOE
[org.gnome.settings-daemon.plugins.updates]
active=false
FOE

# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
  # Show harddisk install in shell dash
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
  # need to move it to anaconda.desktop to make shell happy
  mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

  cat > /usr/share/glib-2.0/schemas/org.cinnamon.remix.gschema.override << FOE
[org.cinnamon]
desktop-effects=false
favorite-apps=['cinnamon-settings.desktop', 'firefox.desktop', 'nautilus.desktop', 'gnome-terminal.desktop', 'anaconda.desktop']
FOE
fi

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat >> /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
DefaultSession=cinnamon.desktop
FOE

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

EOF

%end


## REMIX cinnamon

%post

echo -e "\n**********\nPOST CINNAMON\n**********\n"

# override default gnome settings
cat >> /usr/share/glib-2.0/schemas/org.gnome.remix.gschema.override << GNOME_EOF
[org.gnome.desktop.interface]
font-name='Sans 10'
document-font-name='Sans 10'
monospace-font-name='Monospace 10'

[org.gnome.desktop.wm.preferences]
titlebar-font='Sans Bold 9'

[org.gnome.desktop.background]
show-desktop-icons=true

[org.gnome.nautilus.desktop]
font='Sans Bold 9'

[org.gnome.settings-daemon.plugins.updates]
auto-update-type='none'
frequency-get-updates=0
frequency-get-upgrades=0
GNOME_EOF

# override default settings
cat > /usr/share/glib-2.0/schemas/org.cinnamon.remix.gschema.override << EOF
[org.cinnamon]
desktop-effects=false
favorite-apps=['cinnamon-settings.desktop', 'firefox.desktop', 'nautilus.desktop', 'gnome-terminal.desktop']
EOF

glib-compile-schemas /usr/share/glib-2.0/schemas

%end
