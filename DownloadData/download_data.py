import ocpaccess.download

"""
Two sets of tokens are supplied below -- `common` and `full`.

common  The most common data download.)

full    LARGE FILE WARNING
        For the compressed data, visit [our website].
"""

# Common
common = ['kasthuri11',
          'kat11vesicles',
          'kat11segments',
          'kat11synapses',
          'kat11mito']

# Full
full = ['kasthuri11',
        'kasthuri11cc',
        'kasthuri14Maine',
        'kasthuri14s1colEM',
        'kasthuri14s1colANNO',
        'kat11mojocylinder',
        'kat11redcylinder',
        'kat11greencylinder',
        'ac3',
        'ac4',
        'kat11vesicles',
        'kat11segments',
        'kat11synapses',
        'kat11mito']

download_tokens = []

# Uncomment the next line for `common`
# download_tokens = common

# Uncomment the next line for `full`
# download_tokens = full

for t in download_tokens:
    ocpaccess.download.get_data(
        token =         t,              zoom = 1,
        start =         0,              x_stop =      10752,
        y_start =       0,              y_stop =      13312,
        z_start =       1,              z_stop =      1850,
        location =      t
    )

print("Done.")

# You may want to run the code below (a much smaller sample) first,
# in order to be sure that your environment is set up correctly and
# the server is responding correctly.
"""
ocpaccess.download.get_data(
        token =        "kasthuri11", zoom = 1,
        x_start =      5000,              x_stop =      6000,
        y_start =      5000,              y_stop =      6000,
        z_start =      1,                 z_stop =      185,
        location =     "sample_data"
)
"""
