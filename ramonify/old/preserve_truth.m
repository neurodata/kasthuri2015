%http://braingraph1dev.cs.jhu.edu/ocp/ca/ac3/hdf5/1/5472,6496/8712,9736/1000,1256/
%http://openconnecto.me/ocp/ca/ac3_synTruth_v4/annotation/hdf5/1/5472,6496/8712,9736/1000,1256/

%% AC3 synapse truth

oo = OCP();
oo.setAnnoToken('ac3ac4');
oo.setAnnoChannel('ac3_synapse_truth');

im = h5read('~/Downloads/ac3_synTruth_v4-annotation-hdf5-1-5472_6496-8712_9736-1000_1256-ocpcutout.h5','/annotation/CUTOUT');

V = RAMONVolume;
V.setCutout(im);
V.setXyzOffset([5472,8712,1000]);
V.setResolution(1);
V.setChannel('ac3_synapse_truth')
V.setChannelType(eRAMONChannelType.annotation);
V.setDataType(eRAMONChannelDataType.uint32);

tic, oo.createAnnotation(V), toc

%% AC3 Neuron Truth

oo = OCP();
oo.setAnnoToken('ac3ac4');
oo.setAnnoChannel('ac3_neuron_truth');

im = h5read('~/Downloads/ac3_segments.hdf5','/CUTOUT');

V = RAMONVolume;
V.setCutout(im);
V.setXyzOffset([5472,8712,1000]);
V.setResolution(1);
V.setChannel('ac3_neuron_truth')
V.setChannelType(eRAMONChannelType.annotation);
V.setDataType(eRAMONChannelDataType.uint32);

tic, oo.createAnnotation(V), toc
