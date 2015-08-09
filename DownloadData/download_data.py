import ocpaccess.download

ocpaccess.download.get_data(
        token =     "kasthuri11",
            x_lo =      0,              x_hi =      10752,
            y_lo =      0,              y_hi =      13312,
            z_lo =      1,              z_hi =      1850,
        location =  "data"
)


# You may want to run the code below (a much smaller sample) first,
# in order to be sure that your environment is set up correctly and
# the server is responding correctly.
"""
ocpaccess.download.get_data(
        token =     "kasthuri11",
        x_lo =      5000,              x_hi =      6000,
        y_lo =      5000,              y_hi =      6000,
        z_lo =      1,                 z_hi =      185,
        location = "sample_data"
)
"""
