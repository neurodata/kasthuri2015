import ocp_access

# This script downloads the Kasthuri 2014 Cell data from
# the OCP server.

# Example: Download the full dataset (TAKES A LONG TIME)

ocp_access.get_data(
        token =     "kasthuri11",
        x_lo =      5000,              x_hi =      6000,
        y_lo =      5000,              y_hi =      6000,
        z_lo =      1,              z_hi =      185,
        location =  "data"
)

# Example: Download a small dataset
# =================================
#ocp_access.get_data(
#    token =     "kasthuri11",
#    zoom =      1,
#    x_lo =      0,              x_hi =      10752,
#    y_lo =      0,              y_hi =      13312,
#    z_lo =      1,              z_hi =      1850,
#    location =  "kasthuri-data"
#)
