%% Read and process VAST Ids for everything in the paint

%For segments - identify all segments present in the paint
allPaintIds = [];
for i = 1:size(seg.data,3)
    
    allPaintIds = [allPaintIds; unique(seg.data(:,:,i))];
end
allPaintIds(allPaintIds == 0) = [];

allPaintIds = unique(allPaintIds);
[name,data,firstelement]=scanvastcolorfile('Threecylindermerge_May08_db14_export.txt',1);

clear z
% Get childtreeids for all objects
for i = 1:length(allPaintIds)
    z{i} = getchildtreeids(data,allPaintIds(i));
end

% Anything that has a child will need to be merged into neurons

% Anything that has no children might be a spine
z = 1:length(name);

meta = z(~ismember(z,allPaintIds));

% Get all parents
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
aIId = 6130; %Inhibitory
aMId = 4141; %Myelinated
gId = 4245; %Glia
gAId = 6705; %Astrocytes
gOId = 6707; %Oligodendrocytes

% Add ids from the synapse spreadsheet
syntext = importdata('mmc2.xls');
synIdMap = syntext.data(3:end,1); % known
spineMap = syntext.data(3:end,21); % known
axonMap = syntext.data(3:end,9); % known
dendriteMap = syntext.data(3:end,10); % known

nType.d = intersect(getchildtreeids(data,dId),allPaintIds);
nType.dSpiny = intersect(getchildtreeids(data,dSpinyId),allPaintIds);
nType.dSmooth = intersect(getchildtreeids(data,dSmoothId),allPaintIds);
nType.spines = intersect(unique([getchildtreeids(data,spineId)';spineMap]),allPaintIds); %pull spines from vast + spreadsheet
nType.dOther = setdiff(nType.d,[nType.dSpiny; nType.dSmooth]); %dOther is empty if spines disregarded

% Axons

nType.a = intersect(getchildtreeids(data,aId),allPaintIds);
nType.aExcitatory =  intersect(getchildtreeids(data,aEId),allPaintIds);
nType.aInhibitory = intersect(getchildtreeids(data,aIId),allPaintIds);
nType.aMyelinated = intersect(getchildtreeids(data,aMId),allPaintIds);
nType.aOther = setdiff(nType.a,[nType.aExcitatory; nType.aInhibitory; nType.aMyelinated]);
% Glia

nType.g = intersect(getchildtreeids(data,gId), allPaintIds);
nType.gAstrocyte = intersect(getchildtreeids(data,gAId), allPaintIds);
nType.gOligo = intersect(getchildtreeids(data,gOId), allPaintIds);
nType.gOther = setdiff(nType.g,[nType.gAstrocyte; nType.gOligo]);

x = setdiff(allPaintIds, [nType.a;nType.d;nType.g]);
x1 = [nType.dOther; nType.aOther; nType.gOther];

% Handful of processes that seem to be "scrap" - RAMONGeneric like glia
% TODO:  40 processes that are unknown out of ~6000

%% Assign parent-children based first on the spreadsheet

% Need to identify any discrepancies, but will skip
% Big thing is things that are missing from spreadsheet that affect graph
% so we'll note those

% Otherwise, less of an issue, but still important to check things so that
% we don't get false spines or similar

syntext = importdata('mmc2.xls');
synIdMap = syntext.data(3:end,1);
spineMap = syntext.data(3:end,21);
axonMap = syntext.data(3:end,9);
dendriteMap = syntext.data(3:end,10);

ss_spine = unique(spineMap(spineMap > 0));
ss_axon = unique(axonMap(axonMap > 0));
ss_dendrite = unique(dendriteMap(dendriteMap > 0));

% Which are missing from cylinder paint?

spine_missing = setdiff(ss_spine,allPaintIds);
axon_missing = setdiff(ss_axon,allPaintIds);
dendrite_missing = setdiff(ss_dendrite,allPaintIds);

% What's missing?  7 dendrites and 23 axons, but with common parents
% parents not in paint
unique(getparent(data, axon_missing))
unique(getparent(data, dendrite_missing))
intersect(allPaintIds,[5194,6704,4800,5113]) %parents are containers


% Which of these are not-parents
parents = allPaintIds(pp==-1);
setdiff(ss_axon,parents)
setdiff(ss_dendrite,parents)
% for each non-parent, get a segment
% for each parent get a segment and a neuron

% What's left?  Well, find out what's left and use to create all our
% metadata as before
remaining_ids = setdiff(allPaintIds,[ss_axon;ss_dendrite;ss_spine]);
remaining_non_spine = setdiff(allPaintIds,ss_spine);
ss_neurite = [ss_dendrite; ss_axon];

%% First do the spreadsheet prototype objects

% Seems pretty clear that things don't match well
% But perhaps just missed associations - for now we just rewrite the
% spines because of their importance to connectivity

% Finally, need to add synapse metadata

%% Do for all non-spreadsheet neurons

s = []; sidx = [];

for i = 1:length(allPaintIds)
    s(i).id = allPaintIds(i);
    s(i).name = name{allPaintIds(i)};
    s(i).resolution = seg.resolution;
    s(i).synapses = [];
    if ismember(allPaintIds(i),ss_spine) %override membership
        idxSpine = find(allPaintIds(i) == spineMap);
        idxSpine = idxSpine(1); %assume all the same
        
        parent_immediate = dendriteMap(idxSpine);
        im_parent_idx = find(parent_immediate==allPaintIds);
        parent = pp(im_parent_idx);
        if isempty(parent) || parent == -1 
            parent = parent_immediate;
        else
            disp('remapping! warning warning!')
        end
        s(i).neuron = parent + 10000; %by construction
    else
        parent = pp(i);
        
        if parent == -1
            parent = allPaintIds(i); %own parent
        end
        s(i).neuron = parent + 10000; %by construction
    end
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
    %idxRR(i) = length(idxR);
    n(i).neuron_segment = sidAll(idxR);
end
