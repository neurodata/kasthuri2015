%% RAMONify Kasthuri
% v2
% W. Gray Roncal

uploadToken = 'kasthuri2015_ramon_v2'%'kasthuri2015_ramon_v1';

% In this version, we automagically convert the VAST/Synapse spreadsheet
% data to a standard neurodata format suitable for autoingest. In ge

%% Parsing Annotation Data

% Segments, Cylinders, Synapses, Mitochondria and Vesicles are already
% uploaded as paint

% Segment IDs need to be identified to be sure that all objects are
% captured.

% Synapses need to be broken into distinct object and ids matched to the
% spreadsheet

% Mitochondria need to be broken into distinct objects

% Vesicles need to be be broken into distinct objects


%% Parsing Metadata

% Mitochondria and Vesicles have generic metadata, so should all be the
% same

%% Segment Metadata

% For segments - identify all segments present in the paint
allPaintIds = unique(seg.data);
allPaintIds(allPaintIds == 0) = [];

[name,data,firstelement]=scanvastcolorfile('Threecylindermerge_May08_db14_export.txt',1);

% Get childtreeids for all objects
for i = 1:length(allPaintIds)
    z{i} = getchildtreeids(data,allPaintIds(i));
end

% Anything that has a child will need to be merged into neurons

% Anything that has no children might be a spine
z = 1:length(name);

meta = z(~ismember(z,allPaintIds));

%% Get all parents
clear p pp
pp = -1*ones(length(allPaintIds),1);
for i = 1:length(allPaintIds)
    p = getparent(data,allPaintIds(i));
    
    while p > 0 && ~ismember(p,meta) %no match; object has paint
        pp(i) = p;
        p = getparent(data,p);
    end
end

% These lists are hand curated, by grepping for things like
spineId = [422, 1403, 1064, 1554, 2066, 2147, 2276, 2325, 2538, 3155, 3242]; %All spines (manually curated)
dId = 6149; %All dendrites
dSpinyId = 6702; %Spiny dendrites
dSmoothId = 4716; %Smooth dendrites
aId = 1408; %All Axons
aEId = 3682; %Excitatory
aIId = 4141; %Inhibitory
aMId = 6130; %Myelinated
gId = 4245; %Glia
gAId = 6705; %Astrocytes
gOId = 6707; %Oligodendrocytes

nType.d = intersect(getchildtreeids(data,dId),allPaintIds);

nType.dSpiny = intersect(getchildtreeids(data,dSpinyId),allPaintIds);
nType.dSmooth = intersect(getchildtreeids(data,dSmoothId),allPaintIds);
nType.spines = intersect(getchildtreeids(data,spineId),allPaintIds);
nType.dOther = setdiff(nType.d,[nType.dSpiny; nType.dSmooth]); %dOther is empty if spines disregarded

% Axons

nType.a = intersect(getchildtreeids(data,aId),allPaintIds);
nType.aExcitatory =  intersect(getchildtreeids(data,aEId),allPaintIds);
nType.aInhibitory = intersect(getchildtreeids(data,aIId),allPaintIds);
nType.aMyelinated = intersect(getchildtreeids(data,aMId),allPaintIds);
nType.aOther = setdiff(nType.a,[nType.aExcitatory; nType.aInhibitory; nType.aMyelinate]);
% Glia

nType.g = intersect(getchildtreeids(data,gId), allPaintIds);
nType.gAstrocyte = intersect(getchildtreeids(data,gAId), allPaintIds);
nType.gOligo = intersect(getchildtreeids(data,gOId), allPaintIds);
nType.gOther = setdiff(nType.g,[nType.gAstrocyte; nType.gOligo]);

x = setdiff(allPaintIds, [nType.a;nType.d;nType.g])
x1 = [nType.dOther; nType.aOther; nType.gOther];

% Handful of processes that seem to be "scrap" - RAMONGeneric like glia
% TODO:  35 processes that are unknown out of ~6000
%x = 0.5% of the data

%% Construct prototype object

s = []; sidx = [];

for i = 1:length(allPaintIds)
    s(i).id = allPaintIds(i);
    s(i).name = name{allPaintIds(i)};
    
    parent = pp(i);
    if parent == -1
        parent = allPaintIds(i); %own parent
    end
        s(i).neuron = parent + 10000; %by construction
    
    % assign dendrite specific fields
    if ismember(allPaintIds(i), nType.d)
        s(i).segment_class = eRAMONSegmentClass.dendrite;
        
        if ismember(allPaintIds(i), nType.dSmooth)
            s(i).segment_subtype = 'smooth';
        elseif ismember(allPaintIds(i), nType.dSpiny)
            s(i).segment_subtype = 'spiny';
        else
            s(i).segment_subtype = 'other';
        end
        
        % assign spines
        if ismember(allPaintIds(i), nType.spines)
            s(i).is_spine = 1;
        else
            s(i).is_spine = 0;
        end
        
    elseif ismember(allPaintIds(i), nType.a)
        s(i).segment_class = eRAMONSegmentClass.axon;
        
        if ismember(allPaintIds(i), nType.aExcitatory)
            s(i).segment_subtype = 'excitatory';
        elseif ismember(allPaintIds(i), nType.aInhibitory)
            s(i).segment_subtype = 'inhibitory';
        elseif ismember(allPaintIds(i), nType.aMyelinated)
            s(i).segment_subtype = 'myelinated';
        else
            s(i).segment_subtype = 'other';
        end
    elseif ismember(allPaintIds(i), nType.g)
        s(i).segment_class = eRAMONSegmentClass.unknown;
        
        if ismember(allPaintIds(i), nType.gAstrocyte)
            s(i).segment_subtype = 'glia_astrocyte';
        elseif ismember(allPaintIds(i), nType.gOligo)
            s(i).segment_subtype = 'glia_oligodendrocyte';
        else % ismember(allPaintIds(i), nType.gOther)
            s(i).segment_subtype = 'glia_other';
        end% id
    end
end

%% Create neurons - reverse lookup
n = [];
nAll = unique([s.neuron]);
sidAll = [s.id];
snidAll = [s.neuron];
for i = 1:length(nAll)
    n(i).id = nAll(i);
    % reverse lookup
    idxR = find(nAll(i) == snidAll);
    idxRR(i) = length(idxR);
    n(i).neuron_segment = sidAll(idxR);
end
%%
% name
% cyl 1
% cyl 2
% cyl 3
% size
% object type
% isGlia
% isSpine

% isBouton <- not directly in data

% parent
% neuron class

% derived
%   children (seg - syn is explicit)
%   children (neu - seg)
% id
% isSpine
% isBouton

% axon length
% spine apparatus
%%
for i = 1:length(allPaintIds)
    
    s(end+1).id = allPaintIds(i);
    sidx(end+1,1) = allPaintIds(i);
end

% TODO Delete dead objects?


%% Linking Metadata

%% Presenting Metadata in a standard format
%% Determine bounds
addpath(genpath(pwd))

oo = OCP();

oo.setAnnoToken('kat11greencylinder');

q = OCPQuery;
q.setType(eOCPQueryType.annoDense);
q.setCutoutArgs([0,335],[0,415],[1000,1400],6);

g1 = oo.query(q);

oo.setAnnoToken('kat11redcylinder');
r1 = oo.query(q);

oo.setAnnoToken('kat11mojocylinder');
m1 = oo.query(q);

cyl = uint8(g1.data+m1.data+r1.data);
idx = find(cyl > 0);
[yy,xx,zz] = ind2sub(size(cyl),idx);

pad = [50, 50, 5];
xbox = 8*[min(xx), max(xx)]+[-pad(1),pad(1)];
ybox = 8*[min(yy), max(yy)]+[-pad(2),pad(2)];
zbox = [min(zz), max(zz)]+[-pad(3),pad(3)];

xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];

%% Get data


tic

oo = OCP();
oo.setAnnoToken('kat11greencylinder');
xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];
xbox1 = xbox*4;
ybox1 = ybox*4;
res1 = 1;
res = 3;
q = OCPQuery;
q.setType(eOCPQueryType.annoDense);
q.setCutoutArgs([xbox(1),xbox(2)],[ybox(1),ybox(2)],[zbox(1),zbox(2)],res);

oo.setAnnoToken('kat11greencylinder');
c1 = oo.query(q);

oo.setAnnoToken('kat11mojocylinder');
c2 = oo.query(q);

oo.setAnnoToken('kat11redcylinder');
c3 = oo.query(q);

cc = (c1.data+c2.data+c3.data);
C = RAMONVolume; C.setCutout(cc);
%image(C)
oo.setAnnoToken('kat11segments');
seg = oo.query(q);

oo.setAnnoToken('kat11synapses');
syn = oo.query(q);

oo.setAnnoToken('kat11mito');
mito = oo.query(q);

% TODO - these probably need to be processed at scale 1, because they are
% small and will merge at downsampled resolutions
oo.setAnnoToken('kat11vesicles');
ves = oo.query(q);
toc

% Mask out cylinders
mask = (c1.data + c2.data + c3.data) > 0;

temp = seg.data;
temp(mask == 0) = 0;
seg.setCutout(temp); clear temp

temp = syn.data;
temp(mask == 0) = 0;
syn.setCutout(temp); clear temp

temp = mito.data;
temp(mask == 0) = 0;
mito.setCutout(temp); clear temp

temp = ves.data;
temp(mask == 0) = 0;
ves.setCutout(temp); clear temp


%% % Ramonify Example

%% Skipping - optional - this cell finds correspondence between VAST ids and OCP IDs.
% These should already match from ingest, but if issues arise, this is a debug point

if 0
    !wget http://openconnecto.me/data/public/kasthuri2015/kat11segments.tar.gz
    %unzipped file of seg1ments from Bobby
    segments_location = '/Users/graywr1/code/kasthuri/kat11segments'%'kasthurietal14_segments_paper';
    
    cd(segments_location)
    allPaintIds = uint32([]);
    f = dir('*.png');
    for i = 1225:length(f)
        i
        im = single(imread(f(i).name));
        im = uint32(rgbdecode(im));
        allPaintIds = union(unique(im(:)),allPaintIds);
    end
    
    allPaintIds(allPaintIds == 0) = [];
end

%%  add daniels scripts

% Get directly from DB

%% Now need to upload.
% JUST NEED TO DOUBLE CHECK INDEXING
% All are segments

% Identify neurons
%idx = pp(pp == 0);

neuronRaw = allPaintIds(pp==-1); %this is already indexed
nonParentParent = pp(pp > 0);
nonParentRaw = allPaintIds(pp > 0);
%Initialize Arrays
N = {}; S = {}; Y = {};

% Initialize segments, and link segments to neurons
% This first step links objects that are already neurons (no parents)
for i = 1:length(neuronRaw)
    
    s = RAMONSegment;
    s.setId(neuronRaw(i));
    s.setResolution(3);
    s.setNeuron(neuronRaw(i)+10000);
    
    n = RAMONNeuron;
    n.setId(neuronRaw(i)+10000);
    segVal = [n.segments, neuronRaw(i)];
    n.setSegments(segVal(:)');
    N{end+1} = n;
    S{end+1} = s;
    clear n s
end
%%
clear qqq
%Find all neuron IDs
for i = 1:length(N)
    
    qqq(i) = N{i}.id;
end

% Objects that have one of the already created neurons as a parent
% Segment-Neuron linking
for i = 1:length(nonParentRaw)
    s = RAMONSegment;
    s.setId(nonParentRaw(i));
    s.setNeuron(nonParentParent(i)+10000);
    s.setResolution(3);
    ii = find(qqq == s.neuron);
    try
        segVal = [N{ii}.segments, nonParentRaw(i)];
        
        N{ii}.setSegments(segVal(:)');
    catch
        disp('indexing wrong')
        keyboard
    end
    S{end+1} = s;
    clear s
end

clear ss
for i = 1:length(S)
    ss(i) = S{i}.id;
end

%% Synapse data
syntext = importdata('mmc2.xls');
synIdMap = syntext.data(3:end,1);
spineMap = syntext.data(3:end,21);
axonMap = syntext.data(3:end,9);
dendriteMap = syntext.data(3:end,10);

run('load_synLoc') %manual op - weird nonunicode characters messing things up

syndataRaw = syn.data;
cc = bwconncomp(syndataRaw>0);
synLookupMtx = labelmatrix(cc);
synLoc(:,1) = round(synLoc(:,1)/4);
synLoc(:,2) = round(synLoc(:,2)/4);

synLoc = synLoc - repmat([xbox(1),ybox(1),zbox(1)],[length(synLoc),1]);

rp = regionprops(synLookupMtx,'Area','PixelIdxList');


boxwin = [10,10];
synOut = zeros(size(synLookupMtx));
for i = 1:length(synLoc)
    
    xstart = max(synLoc(i,2)-boxwin(2), 1);
    xstop = min(synLoc(i,2)+boxwin(2), size(syndataRaw,2));
    ystart = max(synLoc(i,1)-boxwin(1),1);
    ystop = min(synLoc(i,1)+boxwin(1), size(syndataRaw,1));
    synPix = synLookupMtx(xstart:xstop, ystart:ystop, synLoc(i,3));
    synPix(synPix == 0) = [];
    remapVal = mode(synPix);
    if remapVal > 0
        synOut(rp(remapVal).PixelIdxList) = synIdMap(i);  %TODO Remap Value
    else
        disp('warning - no pixels found')
    end
end

% synapses not in the list are skipped
for i = 1:length(synIdMap)
    y = RAMONSynapse;
    y.setId(synIdMap(i));
    y.setResolution(3);
    if spineMap(i) > 0
        dlink = spineMap(i);
    else
        dlink = dendriteMap(i);
    end
    
    alink = axonMap(i);
    
    y.addSegment(alink,eRAMONFlowDirection.preSynaptic);
    y.addSegment(dlink,eRAMONFlowDirection.postSynaptic);
    
    %     for i = 1:length(S)
    % ss(i) = S{i}.id;
    % end
    ii = find(ss == alink);
    try
        S{ii}.setSynapses([S{ii}.synapses, alink]);
    catch
        sprintf('No match found for id %d\n', alink)
        
    end
    
    ii = find(ss == dlink);
    try
        S{ii}.setSynapses([S{ii}.synapses, dlink]);
    catch
        sprintf('No match found for id %d\n', dlink)
    end
    
    Y{end+1} = y;
    clear y
end

% TODO ~30 synapses partners are not accounted for

%% Upload
oo = OCP;
oo.setAnnoToken(uploadToken);
oo.setDefaultResolution(3);
oo.setAnnoChannel('neurons')

oo.createAnnotation(S);
% for i = 1:length(S)
% i
%     oo.createAnnotation(S{i});
% end

% TODO - multiple segments in single neuron cause an issue; git issued
oo.createAnnotation(N);
% for i = 1:length(N)
%     i
% oo.createAnnotation(N{i});
% end
seg.setChannel('neurons')
oo.createAnnotation(seg);


oo.setAnnoChannel('synapses')
oo.createAnnotation(Y);

% for i = 1:length(Y)
%     i
% oo.createAnnotation(Y{i});
% end

syn.setChannel('synapses')
oo.createAnnotation(syn)

% mito and vesicles TODO - will need to operate at scale 1

%TODO - mitochondria at scale 3 - possible merging together of adjacent
%objects

data = mito.data;
data = bwlabeln(data>0);
mito.setCutout(data);
cubeUploadDense('openconnecto.me',uploadToken,'mitochondria', mito, ...
    'RAMONOrganelle([],eRAMONDataFormat.dense, [],[], eRAMONOrganelleClass.mitochondria)', 0);


%% Make edgelist graph
synLocation = 'openconnecto.me';
synToken = uploadToken;
synChannel = 'synapses';
synResolution = 3;
neuLocation = 'openconnecto.me';
neuToken = uploadToken;
neuChannel = 'neurons';
neuResolution = 3;
edgeList = graph_retrieval(synLocation, synToken, synChannel, synResolution, [], neuLocation, neuToken, neuChannel, neuResolution, 0)
attredgeWriter(edgeList,'kasthuri_graph_v1.attredge')