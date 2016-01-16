"""
Download data and count mitochondria.

Notes:

"""

import numpy
from scipy import ndimage


def _download():
    # download hdf5
    import ocpy.access.download
    downloaded_files, failed_files = \
            ocpy.access.download.get_data(
                        token='kat11mito', channel='annotation', resolution=3,
                        x_start=694,               x_stop=1794,
                        y_start=1750,              y_stop=2460,
                        z_start=1004,              z_stop=1379,
                        location="./data")

def _convert():
    import glob
    import ocpy.convert.png
    import ocpy.access.Request
    import h5py
    hdf5s = glob.glob('./data/hdf5/*.hdf5')
    for h5file in hdf5s:
        f = h5py.File(h5file)
        z_index = int(h5file.split('-')[-1].split(',')[0])

        for layer in f.get('annotation').get('CUTOUT'):
            print("Splitting layer {}".format(z_index))
            ocpy.convert.png.export_png('data/png/mito_{}.png'.format(z_index), layer)
            z_index += 1


def _import():
    import ocpy.convert.png
    return ocpy.convert.png.import_png_collection('data/png/mito*.png')


def download_mitochondria_cutout():
    # _download()
    # _convert()
    print("data = numpy.array(_import())")
    data = numpy.array(_import())
    print("mask = data > data.mean()")
    mask = data > data.mean()
    print("label_im, nb_labels = ndimage.label(mask)")
    label_im, nb_labels = ndimage.label(mask)
    print("print(nb_labels)")
    print(nb_labels)



def import_data(filename):
    import h5py
    f = h5py.File(FILENAME)
    return f.get('annotation').get('CUTOUT')


def count_mito():
    data = import_data()

download_mitochondria_cutout()
