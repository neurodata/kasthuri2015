%% Vesicle Script

% WARNING:  This script requires about 16GB of RAM to run.
% By chunking the data into smaller parts, one could do this with fewer 
oo = OCP();
oo.setAnnoToken('kat11redcylinder');
xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];
xbox1 = xbox*4;
ybox1 = ybox*4;
res1 = 1;
q = OCPQuery;
q.setType(eOCPQueryType.annoDense);
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[zbox(1),zbox(2)],res1);

%oo.setAnnoToken('kat11redcylinder');
%mask = oo.query(q);

ov = OCP();
ov.setAnnoToken('kat11vesicles')

%% Chunk 1:
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1000,1100],res1);
m1 = oo.query(q);
m1 = logical(m1.data);
v1 = oo.query(q);
%% Chunk 2: 
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1100,1200],res1);
m2 = oo.query(q);
m2 = logical(m2.data);
%% Chunk 3: 
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1200,1300],res1);
m3 = oo.query(q);
m3 = logical(m3.data);

m = m1;
m(:,:,101:200) = m2;
m(:,:,201:300) = m3;

clear m1 m2 m3 m4


%% Chunk 1:
ov = OCP();
ov.setAnnoToken('kat11vesicles')
xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];
xbox1 = xbox*4;
ybox1 = ybox*4;
res1 = 1;
q = OCPQuery;
q.setType(eOCPQueryType.annoDense);


q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1000,1100],res1);
v1 = ov.query(q);
v1 = logical(v1.data);
%%
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1100,1200],res1);
v2 = ov.query(q);
v2 = logical(v2.data);

%% 
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1200,1300],res1);
v3 = ov.query(q);
v3 = logical(v3.data);

v = v1;
v(:,:,101:200) = v2;
v(:,:,201:300) = v3;

%%
%%

%% Chunk 1:
om = OCP();
om.setAnnoToken('kat11mito')
xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];
xbox1 = xbox*4;
ybox1 = ybox*4;
res1 = 1;
q = OCPQuery;
q.setType(eOCPQueryType.annoDense);

q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1000,1100],res1);
m1 = om.query(q);
m1 = logical(m1.data);
%%
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1100,1200],res1);
m2 = om.query(q);
m2 = logical(m2.data);

%% 
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1200,1250],res1);
m3 = om.query(q);
m3 = logical(m3.data);

%%
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1250,1300],res1);
m4 = om.query(q);
m4 = logical(m4.data);

m = m1;
m(:,:,101:200) = m2;
m(:,:,201:250) = m3;
m(:,:,251:300) = m4;

%%
load('vesicle_all.mat')
load('red_cyl_mask.mat')
v(m == 0) = 0;
v_label = bwconncomp(v);

oo = OCP();
oo.setAnnoToken('kasthuri2015_ramon_v2');
oo.setAnnoChannel('vesicles')
%%
% 23523
for i = 23523:23523%23524:v_label.NumObjects
i
o = RAMONOrganelle;
o.setClass(eRAMONOrganelleClass.vesicle);
o.setResolution(1);
pix = v_label.PixelIdxList{i};
[c, r, z] = ind2sub(size(v),pix);
o.setVoxelList([r,c,z]);
oo.createAnnotation(o);
end