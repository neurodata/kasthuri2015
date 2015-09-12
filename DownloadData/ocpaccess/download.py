from __future__ import print_function
import requests
import h5py
import os
import numpy
from PIL import Image
import time

import convert.png


DEFAULT_SERVER =    'http://openconnecto.me'
DEFAULT_FORMAT =    'hdf5'
CHUNK_DEPTH    =    16


def get_info(token, server=DEFAULT_SERVER):
    """
    Get information about a dataset from its token, using the /info endpoint.

    Arguments:
        :token:     ``string`` The token identifying the dataset to investigate

    Returns:
        JSON object containing the content of the /info page.
    """
    url = '/'.join([server, 'ocp', 'ca', token, 'info', ''])
    req = requests.get(url)
    return req.json()


def get_data(token,
             x_start, x_stop,
             y_start, y_stop,
             z_start, z_stop,
             resolution,
             fmt=DEFAULT_FORMAT,
             server=DEFAULT_SERVER,
             location="./",
             ask_before_writing=False):
    """
    Get data from the OCP server.

    Arguments:
        :server:                ``string : DEFAULT_SERVER``
                                Internet-facing server. Must include protocol (e.g. ``https``).
        :token:                 ``string`` Token to identify data to download
        :fmt:                   ``string : 'hdf5'`` The desired output format
        :resolution:            ``int`` Resolution level
        :Q_start:               ``int`` The lower bound of dimension 'Q'
        :Q_stop:                ``int`` The upper bound of dimension 'Q'
        :location:              ``string : './'`` The on-disk location where we'll create /hdf5 and /png
        :ask_before_writing:    ``boolean : False`` Whether to ask (y/n) before creating directories. Default value is `False`.

    Returns:
        :``string[]``: Filenames that were saved to disk.
    """

    total_size = (x_stop - x_start) * (y_stop - y_start) * (z_stop - z_start) * (14./(1000.*1000.*16.))

    print("Downloading approximately " + str(total_size) + " MB.\n")

    # Figure out where we'll be saving files. If the directories don't
    # exist, let's create them now.
    cur_dir = os.getcwd()

    location = location if location else os.getcwd()
    try:
        os.mkdir(location)
    except Exception as e:
        print("Directory /" + location + " already exists, not creating.")

    os.chdir(location)

    try:
        os.mkdir('hdf5'); os.mkdir('png');
    except Exception as e:
        print("Data directories already exist, not creating /hdf5 or /png.")

    if ask_before_writing:
        confirm = raw_input("The data will be saved to /" + location + ".\n" +
              "Continue? [yn] ")
        if confirm is 'n':
            return False;

    fmt = "hdf5" # Hard-coded for now to minimize server-load

    # The array of local files that we create
    local_files = []
    failed_files = []

    # OCP stores cubes of z-size = CHUNK_DEPTH. To be efficient,
    # we'll download in CHUNK_DEPTH-z-slice units.
    if z_stop - z_start <= CHUNK_DEPTH:
        # We don't have to split, just download.
        result = _download_data(server, token, fmt, resolution,
                            x_start, x_stop,
                            y_start, y_stop,
                            z_start, z_stop, "hdf5")
        if result[0] is False:
            print(" !! Failed on " + result[1])
            failed_files.append(result[1])
        else:
            local_files.append(result[1])
    else:
        # We need to split into CHUNK_DEPTH-slice chunks.
        z_last = z_start
        while z_last < z_stop:
            # Download from z_last to z_last + CHUNK_DEPTH OR
            # z_stop, whichever is smaller
            if z_stop <= z_last + CHUNK_DEPTH:
                # Download from z_last to z_stop
                result = _download_data(server, token, fmt, resolution,
                            x_start, x_stop,
                            y_start, y_stop,
                            z_last, z_stop, "hdf5")
                if result[0] is False:
                    print(" !! Failed on " + result[1])
                    failed_files.append(result[1])
                else:
                    local_files.append(result[1])
            else:
                # Download from z_last to z_last + CHUNK_DEPTH
                result = _download_data(server, token, fmt, resolution,
                            x_start, x_stop,
                            y_start, y_stop,
                            z_last, z_last + CHUNK_DEPTH, "hdf5")
                if result[0] is False:
                    print(" !! Failed on " + result[1])
                    failed_files.append(result[1])
                else:
                    local_files.append(result[1])

            z_last += CHUNK_DEPTH + 1

    # We now have an array, `local_files`, holding all of the
    # files that we downloaded.
    # print([i for i in local_files])
    files = convert_files_to_png(token, fmt, resolution,
                                  x_start, x_stop,
                                  y_start, y_stop,
                                  z_start, z_stop,
                                  local_files)
    # Return to starting directory
    os.chdir(cur_dir)
    return (files, failed_files)

def convert_files_to_png(token, fmt, resolution,
                        x_start, x_stop,
                        y_start, y_stop,
                        z_start, z_stop,
                        file_array):
    # Because we downloaded these files in sequence by z-index
    # (which is bad, it's better to mosaic the coords in x & y as well)
    # we can simply 'slice' them into individual png files so they're 1
    # unit 'thick' (like a virtual microtome.)
    i = z_start
    print("Converting HDF5 files to single-layer PNGs.")
    for hdf_file in file_array:
        print("Slicing " + hdf_file)
        f = h5py.File(hdf_file, "r")
        # OCP stores data inside the 'cutout' h5 dataset
        data_layers = f.get('CUTOUT')

        out_files = []
        for layer in data_layers:
            # Filename is formatted like the request URL but `/` is `-`
            png_file = "-".join([
                token, fmt, str(resolution),
                str(x_start) + "," + str(x_stop),
                str(y_start) + "," + str(y_stop),
                str(i).zfill(6)
            ]) + ".png"

            out_files.append(
                convert.png.export_png("png/" + png_file, layer))
            print(".", end="")
            i += 1
        print("\n")
        return out_files



def _download_data(server, token, fmt, resolution, x_start, x_stop, y_start, y_stop, z_start, z_stop, location):
    """
    Download the actual data from the server. Uses 1MB chunks when saving.
    Returns the filename stored locally. Specify a save-location target in get_data.
    """
    print("Downloading " + str(z_start) + "-" + str(z_stop))
    # Build a string that holds the full URL to request.

    request_data = [
        server, 'ocp', 'ca',                # Boilerplate server URL
        token, fmt, str(resolution),        # Set token, format, and resolution
        str(x_start) + "," + str(x_stop),   # X
        str(y_start) + "," + str(y_stop),   # Y
        str(z_start) + "," + str(z_stop),   # Z
        ""                                  # Trailing '/'
    ]

    request_url = '/'.join(request_data)
    file_name   = location + "/" + '-'.join(request_data[3:-1]) + "." + fmt

    # Create a `requests` object.
    req = requests.get(request_url, stream=True)
    if req.status_code is not 200:
        print(" !! Error encountered... Trying again in 5s...")
        # Give the server five seconds to catch its breath
        # TODO: ugh
        time.sleep(5)
        req2 = requests.get(request_url, stream=True)
        if req2.status_code is not 200:
            return (False, file_name)
        else:
            req = req2
    # Now download (chunking to 1024 bytes from the stream)
    with open(file_name, 'wb+') as f:
        for chunk in req.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)
                f.flush()

    return (True, file_name)
