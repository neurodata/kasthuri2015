import ocpaccess.download

ocpaccess.download.get_data(
            token =        "kasthuri11", zoom = 1,
            x_start =      0,              x_stop =      10752,
            y_start =      0,              y_stop =      13312,
            z_start =      1,              z_stop =      1850,
            location =     "data"
)


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
