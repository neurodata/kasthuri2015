# Data Access
These scripts are written to work with 2.7 and (ideally, but untestedly) Python 3. A script to download the [*CELL*, Kasthuri (July 30 2015)](http://www.openconnectomeproject.org/#!kasthuri11/c12r2) data) is included, named `download_data.py`.

In order to set up the python environment, you'll need to download a few libraries. You can use `pip` for this, and run `pip install -r requirements` from inside this directory, or you can manually install each of the libraries listed in the `requirements` file.

**To install the necessary OCP packages**, you can run the `get_ocp_packages.sh` bash script in this directory. Otherwise, you can download them manually: You'll need the [ocpconvert](https://github.com/openconnectome/ocpConvert) Python package, which handles conversion of OCP datatypes, as well as the [ocpaccess](https://github.com/openconnectome/ocpAccess) package which handles the actual download of data from OCP servers.
