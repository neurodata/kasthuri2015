%% Vesicle Script

% WARNING:  This script requires about 16GB of RAM to run.
% By chunking the data into smaller parts, one could do this with fewer 
oo = OCP();
xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];
xbox1 = xbox*4;
ybox1 = ybox*4;
res1 = 1;
q = OCPQuery;
q.setType(eOCPQueryType.annoDense);
q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[zbox(1),zbox(2)],res1);

oo.setAnnoToken('kat11redcylinder');
mask = oo.query(q);

ov = OCP();
ov.setAnnoToken('kat11vesicles');
xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];
xbox1 = xbox*4;
ybox1 = ybox*4;
res1 = 1;
q = OCPQuery;
q.setType(eOCPQueryType.annoDense);

q.setCutoutArgs([xbox1(1),xbox1(2)],[ybox1(1),ybox1(2)],[1000,1300],res1);
vv = ov.query(q);


%% parse vesicles
ves = vv.data;
ves(mask.data(1:300) == 0) = 0;
v_label = bwconncomp(ves>0,8);
v_label.NumObjects
v_label_matrix = labelmatrix(v_label);
oo = OCP();
oo.setAnnoToken(uploadToken);
oo.setAnnoChannel('vesicles');

chunk = 1;
for i = 1:chunk:size(v_label_matrix,3)
    i
    max = min(i+chunk,size(v_label_matrix,3));
    vv.setCutout(v_label_matrix(:,:,i:max));
    vv.setXyzOffset([xbox1(1),ybox1(1),zbox(1)+i-1]);
    vv.setChannel('vesicles');
    oo.createAnnotation(vv);
end




clear o

for i = 1:v_label.NumObjects    
    if mod(i,1000) == 0
        sprintf('Now processing vesicle %d of %d...\n',i,v_label.NumObjects)
    end

    o{i} = RAMONOrganelle;
    o{i}.setClass(eRAMONOrganelleClass.vesicle);
    o{i}.setResolution(1);
end

tic
oo.createAnnotation(o)
toc



%% MITOCHONDRIA

oo = OCP();

xbox = [694,1794]; %cleaning up for ease of remembering
ybox = [1750, 2460];
zbox = [1004, 1379];

q = OCPQuery;
q.setType(eOCPQueryType.annoDense);
q.setCutoutArgs([xbox(1),xbox(2)],[ybox(1),ybox(2)],[zbox(1),zbox(2)],3);

oo.setAnnoToken('kat11redcylinder');
c0 = oo.query(q);

oo.setAnnoToken('kat11greencylinder');
c1 = oo.query(q);

oo.setAnnoToken('kat11mojocylinder');
c2 = oo.query(q);

oo.setAnnoToken('kat11mito');

m = oo.query(q);


%% parse mitochondria

c = (c0.data+c1.data+c2.data) > 0;
mito = m.data;
mito(c == 0) = 0;

mm = bwconncomp(mito, 26);

mm.NumObjects

% get rid of small objects
z = labelmatrix(mm);
rp = regionprops(z,'PixelIdxList','Area');
for i = 1:length(rp)
    if rp(i).Area < 5 %TODO somewhat arbitrary
        z(rp(i).PixelIdxList) = 0;
    end
end

mm = bwconncomp(z, 26);
mm.NumObjects


mm_label_matrix = labelmatrix(mm);
oo = OCP();
oo.setAnnoToken(uploadToken);
oo.setAnnoChannel('mitochondria')
m.setCutout(mm_label_matrix);
m.setChannel('mitochondria')
oo.createAnnotation(m);

clear o
tic
for i = 1:mm.NumObjects    
    if mod(i,1000) == 0
        sprintf('Now processing mitochondria %d of %d...\n',i,mm.NumObjects)
    end

    o{i} = RAMONOrganelle;
    o{i}.setClass(eRAMONOrganelleClass.mitochondria);
    o{i}.setResolution(3);
end


oo.createAnnotation(o);
toc
disp('done')

% 
% oo = OCP();
% oo.setAnnoToken(uploadToken);
% oo.setAnnoChannel('mitochondria')
% %
% for i = 1:mm.NumObjects
%     if mod(i,25) == 0
%         sprintf('Now processing mitochondria %d of %d...\n',i,mm.NumObjects)
%     end
% 
%     o = RAMONOrganelle;
%     o.setClass(eRAMONOrganelleClass.mitochondria);
%     o.setResolution(3);
%     pix = mm.PixelIdxList{i};
%     [c, r, z] = ind2sub(size(m),pix);
%     o.setVoxelList([r,c,z]+repmat([xbox(1),ybox(1),zbox(1)],[length(r),1]));
%     oo.createAnnotation(o);
% end
% 
% %%
% oo.setAnnoToken(uploadToken);
% oo.setAnnoChannel('vesicles')
% %
% for i = 1:v_label.NumObjects
%     if mod(i,1000) == 0
%         sprintf('Now processing vesicle %d of %d...\n',i,v_label.NumObjects)
%     end
% 
%     o = RAMONOrganelle;
%     o.setClass(eRAMONOrganelleClass.vesicle);
%     o.setResolution(1);
%     pix = v_label.PixelIdxList{i};
%     [c, r, z] = ind2sub(size(vv),pix);
%     o.setVoxelList([r,c,z]+repmat([xbox1(1),ybox1(1),zbox(1)],[length(r),1]));
%     oo.createAnnotation(o);
% end
%%vv.setXyzOffset([xbox(1),ybox(1),zbox(1)])

%v_label_matrix = imdilate(v_label_matrix,strel('disk',1));
%vv.setCutout(imresize(v_label_matrix,0.25,'nearest'));
%vv.setResolution(3);

% %%