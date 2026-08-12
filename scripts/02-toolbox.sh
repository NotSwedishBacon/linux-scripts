#!/bin/bash
cat << EOF | sudo tee /usr/local/bin/xdg-open
#!/bin/sh
exec flatpak-spawn --host -- xdg-open \$@
EOF
sudo chmod +x /usr/local/bin/xdg-open

cp /usr/share/applications/code.desktop /usr/share/applications/code-url-handler.desktop ~/.local/share/applications/
TOOLBOX_NAME=$(cat /run/.containerenv | grep 'name=' | sed -e 's/^name="\(.*\)"$/\1/')
sed -i "s/Exec=\/usr\/share\/code\/code/Exec=\/usr\/bin\/toolbox run -c \"$TOOLBOX_NAME\" code/g" ~/.local/share/applications/code.desktop ~/.local/share/applications/code-url-handler.desktop
