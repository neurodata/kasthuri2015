echo "Downloading ocpAccess..."
git clone https://github.com/openconnectome/ocpAccess _ocpA

mv ./_ocpA/python/ocpaccess .
rm -rf ./_ocpA
