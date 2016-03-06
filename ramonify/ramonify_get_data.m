% ramonify get data
% get masks and all image data
% crop to three cylinders, at least for now

%% GET DATA
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

%% %% Determine bounds

if 0  % did first time through!
    
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
end


%% Skipping - optional - this cell finds correspondence between VAST ids and OCP IDs.
% These should already match from ingest, but if issues arise, this is a debug point

if 0
    %!wget http://openconnecto.me/data/public/kasthuri2015/old/kat11segments.tar.gz
    %unzipped file of seg1ments from Bobby
    segments_location = '/Users/will/code/kasthuri/ramonify/kat11segments'%'kasthurietal14_segments_paper';
    
    cd(segments_location)
    allPaintIds = uint32([]);
    f = dir('*.png');
    parfor i = 1:length(f)
        i
        im = single(imread(f(i).name));
        im = uint32(rgbdecode(im));
        allPaintIds = union(unique(im(:)),allPaintIds);
    end
    
    allPaintIds(allPaintIds == 0) = [];
end

%% Get all segment data
if 0
    clear im
    oo = OCP();
    oo.setAnnoToken('kat11segments');
    oo.setAnnoChannel('annotation');
    
    q = OCPQuery;
    q.setType(eOCPQueryType.annoDense);
    im = uint16(zeros(3327,2687,1850));
    %
    for z = 1:16:1850
        z
        startIdx = z;
        stopIdx = min(1851,z+16);
        q.setCutoutArgs([0,2687],[0,3327],[startIdx, stopIdx],3);
        temp = oo.query(q);
        im(:,:,startIdx:stopIdx-1) = temp.data;
    end
    
    seg = RAMONVolume;
    seg.setCutout(im);
    clear im
    
end