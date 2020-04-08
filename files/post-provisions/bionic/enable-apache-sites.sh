#!/usr/bin/env bash

# enable any custom sites added to files/apache2/sites-available/

echo "Enabling apache2 subdomains domains for dot apps"
sudo bash <<EOF
    a2ensite admin.dev.dot.paratech.local
    a2ensite api.dev.dot.paratech.local
    systemctl reload apache2
EOF
