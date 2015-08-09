echo "Downloading ocpAccess..."
git clone https://github.com/openconnectome/ocpAccess
echo "Downloading ocpConvert..."
git clone https://github.com/openconnectome/ocpConvert

mv ./ocpAccess/python/ocpaccess ./ocpaccess/
rm -rf ./ocpAccess
mv ./ocpConvert/python/ocpconvert ./ocpconvert/
rm -rf ./ocpConvert
