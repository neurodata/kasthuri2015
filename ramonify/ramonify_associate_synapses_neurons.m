% This script assumes that neurons and synapses have already been found

% synapse association is pretty straightforward, unless the ids are missing
% then time for judo % synapses not in the list are skipped

c = 0;
rp = regionprops(synOut,'PixelIdxList');
syntext = importdata('mmc2.xls');
axonType = syntext.data(3:end,13);
vesicleCount = syntext.data(3:end,14);
multiSynBouton = syntext.data(3:end,16);
synapseLocation = syntext.data(3:end,18);
psdSize = syntext.data(3:end,20);

ss = [s.id];
for i = 1:length(synIdMap)
    
    y(i).id = synIdMap(i);
    y(i).resolution = 3;
    
    y(i).psdSize = psdSize(i);
    
    if synapseLocation(i) == 1
        y(i).synapseLocation = 'spine'; %spine or shaft (1 = spine, 0 = shaft)
    else
        y(i).synapseLocation = 'shaft'; %spine or shaft (1 = spine, 0 = shaft)
    end
    
    if multiSynBouton(i) == 1
        y(i).multiSynapseBouton = 'yes';
    elseif multiSynBouton(i) == 0
        y(i).multiSynapseBouton = 'no';
    else
        y(i).multiSynapseBouton = 'unknown';
    end
    
    if vesicleCount(i) > -1
        y(i).vesicleCount =vesicleCount(i); %-1 not available
    else
        y(i).vesicleCount = 'unknown';
    end
    
    if axonType(i) == 1
        y(i).axonSynapseType = 'terminal';
    elseif axonType(i) == 0
        y(i).axonSynapseType = 'en-passant';
    else
        y(i).axonSynapseType = 'unknown';
    end
    
    if spineMap(i) > 0
        dlink = spineMap(i);
    else
        dlink = dendriteMap(i);
    end
    
    alink = axonMap(i);
    
    ii = find(ss == alink);
    try
        s(ii).synapses = [s(ii).synapses, y(i).id];
    catch
        fprintf('No match found for id %d\n', alink)
        
        pix = seg.data(rp(y(i).id).PixelIdxList);
        pix(pix == alink) = [];
        pix(pix == dlink) = [];
        pix(pix == 0) = [];
        if mode(pix) > 0
            fprintf('Recovering synapse!\n')
            alink = mode(pix);
            
            ii = find(ss == alink);
            s(ii).synapses = [s(ii).synapses, y(i).id];
        else
            c = c+1;
        end
    end
    
    ii = find(ss == dlink);
    try
        s(ii).synapses = [s(ii).synapses, y(i).id];
    catch
        fprintf('No match found for id %d\n', dlink)
        
        pix = seg.data(rp(y(i).id).PixelIdxList);
        pix(pix == alink) = [];
        pix(pix == dlink) = [];
        pix(pix == 0) = [];
        if mode(pix) > 0
            fprintf('Recovering synapse!\n')
            dlink = mode(pix);
            ii = find(ss == dlink);
            s(ii).synapses = [s(ii).synapses, y(i).id];
        else
            c = c+1;
        end
    end
    y(i).presynaptic = alink;
    y(i).postsynaptic = dlink;
    
end

