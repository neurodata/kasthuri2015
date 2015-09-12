import imp
from convert import *

_required_packages = [
            'requests',
            'h5py',
            'numpy',
            'PIL',
            ]


for p in _required_packages:
    try:
        imp.find_module(p)
    except ImportError:
        print("======================= WARNING =======================\n" +
            p + " required but not found. You may experience some" +
            "\nunexpected errors when using ocpaccess.\n" +
            "\nTo install all packages, type `pip install -r requirements`" +
            "\nfrom the command-line in the root of the python/ directory.")
