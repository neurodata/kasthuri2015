oo = OCP();
oo.setServerLocation('http://openconnecto.me')
oo.setAnnoToken('ac3ac4');
oo.setAnnoChannel('ac4membraneIDSIA');

q = OCPQuery(eOCPQueryType.probDense);
%q.setCutoutArgs([4200 ], [5240, 6664], [1080, 1220], 1);


for i = 1:100
    i
    m = RAMONVolume;
    m.setXyzOffset([4400,5440,1200-i]);
    m.setResolution(1);
    %m.setUploadType(eRAMONUploadDataType.prob32)
    temp = 1-single(imread('train-membranes-idsia.tif',i))/255;
    temp = temp(end:-1:1,end:-1:1);
    m.setDataType(eRAMONChannelDataType.float32);
    m.setChannel('ac4membraneIDSIA');
    m.setChannelType(eRAMONChannelType.image);
    m.setCutout(temp);
    oo.createAnnotation(m)
end

%%

%http://braingraph1dev.cs.jhu.edu/ocp/ca/ac3/hdf5/1/5472,6496/8712,9736/1000,1256/
%http://openconnecto.me/ocp/ca/ac3_synTruth_v4/annotation/hdf5/1/5472,6496/8712,9736/1000,1256/

%% AC3 synapse truth

oo = OCP();
oo.setAnnoToken('ac3ac4');
oo.setAnnoChannel('ac3_synapse_truth');

im = h5read('~/Downloads/ac3_synTruth_v4-annotation-hdf5-1-5472_6496-8712_9736-1000_1256-ocpcutout.h5','/annotation/CUTOUT');
im = permute(im,[2,1,3]);

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
im = permute(im,[2,1,3]);

V = RAMONVolume;
V.setCutout(im);
V.setXyzOffset([5472,8712,1000]);
V.setResolution(1);
V.setChannel('ac3_neuron_truth')
V.setChannelType(eRAMONChannelType.annotation);
V.setDataType(eRAMONChannelDataType.uint32);

tic, oo.createAnnotation(V), toc

%% ac3 membranes IDSIA

oo = OCP();
oo.setServerLocation('http://openconnecto.me')
oo.setAnnoToken('ac3ac4');
oo.setAnnoChannel('ac3membraneIDSIA');

for i = 1:100
    i
    m = RAMONVolume;
    m.setXyzOffset([5472,8712,1256-i]);

    m.setResolution(1);
    %m.setUploadType(eRAMONUploadDataType.prob32)
    temp = 1-single(imread('test-membranes-idsia.tif',i))/255;
    %temp = temp(end:-1:1,end:-1:1);
    m.setDataType(eRAMONChannelDataType.float32);
    m.setChannel('ac3membraneIDSIA');
    m.setChannelType(eRAMONChannelType.image);
    m.setCutout(temp);
    oo.createAnnotation(m)
end

%% AC4

odown = OCP();
odown.setImageToken('kasthuri11cc');
odown.setAnnoToken('ac4_raw');

% Find Synapses

% Here we download from an existing database
%http://openconnecto.me/ocp/overlay/0.7/openconnecto.me/kasthuri11cc/image/openconnecto.me/ac4_raw/neuron/xy/1/4400,5424/5440,6464/1105/
odown.setAnnoChannel('synapse');

q = OCPQuery;
q.setType(eOCPQueryType.annoDense);
q.setCutoutArgs([4400,5424],[5440,6464],[1100,1200],1);

synPaint = odown.query(q);


% Find Neuron Segments

% Here we download raw data from an existing database
odown.setAnnoChannel('neuron');

neuPaint = odown.query(q);

%%
oo = OCP();
oo.setAnnoToken('ac3ac4');
oo.setAnnoChannel('ac4_synapse_truth');

%im = h5read('~/Downloads/ac3_synTruth_v4-annotation-hdf5-1-5472_6496-8712_9736-1000_1256-ocpcutout.h5','/annotation/CUTOUT');
%im = permute(im,[2,1,3]);

V = synPaint;
%V.setCutout(im);
V.setXyzOffset([4400,5440,1100]);
V.setResolution(1);
V.setChannel('ac4_synapse_truth')
V.setChannelType(eRAMONChannelType.annotation);
V.setDataType(eRAMONChannelDataType.uint32);

tic, oo.createAnnotation(V), toc

%% AC4 Neuron Truth

oo = OCP();
oo.setAnnoToken('ac3ac4');
oo.setAnnoChannel('ac4_neuron_truth');

% im = h5read('~/Downloads/ac3_segments.hdf5','/CUTOUT');
% im = permute(im,[2,1,3]);

V = neuPaint;
V.setXyzOffset([4400,5440,1100]);
V.setResolution(1);
V.setChannel('ac4_neuron_truth')
V.setChannelType(eRAMONChannelType.annotation);
V.setDataType(eRAMONChannelDataType.uint32);

tic, oo.createAnnotation(V), toc
