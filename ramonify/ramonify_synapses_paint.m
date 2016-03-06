syntext = importdata('mmc2.xls');
synIdMap = syntext.data(3:end,1);

pix = [0.006, 0.006, 0.030];

synLoc = [];
for i = 3:size(syntext.textdata,1)
    synLoc(end+1,:) = syntext.data(i,2:4)./pix;
end

syndataRaw = syn.data;

s4 = syndataRaw;
%s4 = imdilate(syndataRaw,strel('ball',3,1));
b4 = bwconncomp(s4>0,26);
synLookupMtx = labelmatrix(b4);
t = labelmatrix(b4);
synLoc(:,1) = round(synLoc(:,1)/4);
synLoc(:,2) = round(synLoc(:,2)/4);

synLoc = synLoc - repmat([xbox(1)-1,ybox(1)-1,zbox(1)-1],[length(synLoc),1]);

rp = regionprops(synLookupMtx,'Area','PixelIdxList');

% kludge
%synLoc(895,:) = [553, 773, 178];
synOut = zeros(size(synLookupMtx));
c = 0;
cc = [];
doFirst = [2];
doRest = 1:length(synLoc);
doRest(ismember(doRest,doFirst)) = [];


% do precomputed synapses

%Synapse 2 and 986 are duplicate locations!!!

% Truth synapse 2 -> 7
s1 = imdilate(seg.data==3837,strel('disk',3));
s2 = imdilate(seg.data==3422,strel('disk',3));
unique(synLookupMtx(s1>0 & s2>0));
synOut(rp(51).PixelIdxList) = 2;
synLookupMtx(rp(51).PixelIdxList) = 0;

% synapse 2 -> 51 

% Truth synapse 986 - needs a bigger bounding box
s1 = imdilate(seg.data==4228,strel('disk',7));
s2 = imdilate(seg.data==3316,strel('disk',7));
% seems to actually be as advertised.

% 1633 gets overwritten
doRest(doRest == 1633) = [];
doRest = [1633,doRest];

ireject = [];
for i = doRest
    i
    boxwin = [5,5,2];

    xstart = uint16(max(synLoc(i,2)-boxwin(1), 1));
    xstop = uint16(min(synLoc(i,2)+boxwin(1), size(synLookupMtx,1)));
    ystart = uint16(max(synLoc(i,1)-boxwin(2),1));
    ystop = uint16(min(synLoc(i,1)+boxwin(2), size(synLookupMtx,2)));
    zstart = uint16(max(synLoc(i,3)-boxwin(3),1));
    zstop = uint16(min(synLoc(i,3)+boxwin(3), size(synLookupMtx,3)));
    
    synPix = synLookupMtx(xstart:xstop, ystart:ystop, zstart:zstop);
    synPix(synPix == 0) = [];
    remapVal = mode(synPix(:));
   % keyboard
    if length(unique(synPix)) > 1 % more than one possible match
        cc = [cc, i];
    end
        
    if remapVal > 0
        synOut(rp(remapVal).PixelIdxList) = synIdMap(i);  %TODO Remap Value
        synLookupMtx(rp(remapVal).PixelIdxList) = 0;
    else
        %disp('warning - no pixels found')
        %keyboard
        ireject = [ireject, i];
        c = c + 1;
    end
end

c

% 145 has no assignment, possibly because it was already taken
% for now, just drop a 7x7x3 box - this is broken

xx = round(synLoc(145,:));
synOut(xx(2)-3:xx(2)+3,xx(1)-3:xx(1)+3, xx(3)-1:xx(3)+1) = 145;

% 268 has no assignment, possibly because it was already taken
xx = round(synLoc(268,:));
synOut(xx(2)-3:xx(2)+3,xx(1)-3:xx(1)+3, xx(3)-1:xx(3)+1) = 145;

syn = RAMONVolume;
syn.setCutout(synOut);
syn.setResolution(3);
syn.setXyzOffset([xbox(1),ybox(1),zbox(1)]);
syn.setChannel('synapses');
% To find synapses, we first try finding all synapses within a small
% epsilon.  Naively there are a few hundred extra synapses, but we believe
% this is due to connected component issues in automation.  

% Two synapses are problematic with our greedy match algorithm; we reorder
% and adjust centroids to resolve these discrepancies.  Additional synapses
% are discarded as fragments.  We verify this is a reasonable approximation
% by the following code, showing all synapse pixels that are unmarked are
% near a labeled synapse.  This is likely not perfect but quite close.

%z = imdilate(synOut, strel('ball',3,3));
%t = labelmatrix(b4);
%tt = t; tt(z > 0) = 0;
%sum(tt(:))
