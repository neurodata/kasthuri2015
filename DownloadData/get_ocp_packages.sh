echo "Downloading ocpAccess..."
git clone https://github.com/openconnectome/ocpAccess _ocpA
echo "Downloading ocpConvert..."
git clone https://github.com/openconnectome/ocpConvert _ocpC

mv ./_ocpA/python/ocpaccess .
rm -rf ./_ocpA
mv ./_ocpC/python/ocpconvert .
rm -rf ./_ocpC
