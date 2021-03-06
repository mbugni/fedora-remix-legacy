## f22-kde-desktop.ks

%include f22-base-desktop.ks
%include f22-kde-packages.ks

%post

# set default GTK+ theme for root (see #683855, #689070, #808062)
mkdir -p /etc/gtk-2.0
cat > /etc/gtk-2.0/gtkrc << EOF_GTK2
include "/usr/share/themes/Adwaita/gtk-2.0/gtkrc"
gtk-icon-theme-name = "breeze"
gtk-fallback-icon-theme = "hicolor"
EOF_GTK2

# add initscript
cat >> /etc/rc.d/init.d/livesys << EOF

# set up autologin for user liveuser
if [ -f /etc/sddm.conf ]; then
sed -i 's/^#User=.*/User=liveuser/' /etc/sddm.conf
sed -i 's/^#Session=.*/Session=plasma.desktop/' /etc/sddm.conf
else
cat > /etc/sddm.conf << SDDM_EOF
[Autologin]
User=liveuser
Session=plasma.desktop
SDDM_EOF
fi

# add liveinst.desktop to favorites menu
mkdir -p /home/liveuser/.config/
cat > /home/liveuser/.config/kickoffrc << MENU_EOF
[Favorites]
FavoriteURLs=/usr/share/applications/firefox.desktop,/usr/share/applications/kde4/dolphin.desktop,/usr/share/applications/systemsettings.desktop,/usr/share/applications/org.kde.konsole.desktop,/usr/share/applications/liveinst.desktop
MENU_EOF

# show liveinst.desktop on desktop and in menu
sed -i 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop

# chmod +x ~/Desktop/liveinst.desktop to disable KDE's security warning
chmod +x /usr/share/applications/liveinst.desktop

# Set akonadi backend
mkdir -p /home/liveuser/.config/akonadi
cat > /home/liveuser/.config/akonadi/akonadiserverrc << AKONADI_EOF
[%General]
Driver=QSQLITE3
AKONADI_EOF

# Disable plasma-pk-updates
sed -i \
    -e "s|^X-KDE-PluginInfo-EnabledByDefault=true|X-KDE-PluginInfo-EnabledByDefault=false|g" \
    /usr/share/kservices5/plasma-applet-org.kde.plasma.pkupdates.desktop

# Disable baloo
cat > /home/liveuser/.config/baloofilerc << BALOO_EOF
[Basic Settings]
Indexing-Enabled=false
BALOO_EOF

# Disable kres-migrator
cat > /home/liveuser/.kde/share/config/kres-migratorrc << KRES_EOF
[Migration]
Enabled=false
KRES_EOF

# make sure to set the right permissions and selinux contexts
chown -R liveuser:liveuser /home/liveuser/
restorecon -R /home/liveuser/

EOF

%end


%post

echo ""
echo "****************"
echo "POST KDE DESKTOP"
echo "****************"

# Defaults for user configuration
mkdir -p /etc/skel/.config

# Disable baloo
cat > /etc/kde/baloofilerc << BALOO_EOF
[Basic Settings]
Indexing-Enabled=false
BALOO_EOF

cat > /etc/skel/.config/baloofilerc << BALOO_EOF
[Basic Settings]
Indexing-Enabled=false
BALOO_EOF

# Set Plasma locale
cat > /etc/skel/.config/plasma-localerc << PLASMALOCALE_EOF
[Formats]
LANG=it_IT.UTF-8

[Translations]
LANGUAGE=it
PLASMALOCALE_EOF

# Add defaults to favorites menu
cat > /etc/skel/.config/kickoffrc << KICKOFF_EOF
[Favorites]
FavoriteURLs=/usr/share/applications/systemsettings.desktop,/usr/share/applications/firefox.desktop,/usr/share/applications/kde4/dolphin.desktop,/usr/share/applications/org.kde.konsole.desktop
KICKOFF_EOF

# System wide settings
cat > /etc/skel/.config/kdeglobals << GLOBALS_EOF
[KDE]
SingleClick=false

[Locale]
Country=it

[Translations]
LANGUAGE=it
GLOBALS_EOF

# Launcher settings
cat > /etc/skel/.config/klaunchrc << KLAUNCHRC_EOF
[BusyCursorSettings]
Timeout=6

[TaskbarButtonSettings]
Timeout=6
KLAUNCHRC_EOF

# Avoid konqueror preload
cat > /etc/kde/konquerorrc << KONQUEROR_EOF
[Reusing]
AlwaysHavePreloaded=false
MaxPreloadCount=0
PreloadOnStartup=false
KONQUEROR_EOF

# Session settings
cat > /etc/skel/.config/ksmserverrc << KSMSERVERRC_EOF
[General]
loginMode=default
KSMSERVERRC_EOF

# Set Thunderbird as default email client
cat > /etc/kde/emaildefaults << EMAILDEFAULTS_EOF
[Defaults]
Profile=Default

[PROFILE_Default]
EmailClient[\$e]=thunderbird
TerminalClient=false
EMAILDEFAULTS_EOF

%end
