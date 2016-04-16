%ramonify upload

%% UPLOAD PAINT

oo = OCP();
oo.setAnnoToken(uploadToken);
oo.setAnnoChannel('neurons');
seg.setChannel('neurons');
oo.createAnnotation(seg)

oo.setAnnoChannel('synapses');
syn.setDataType(eRAMONChannelDataType.uint32);
syn.setChannelType(eRAMONChannelType.annotation);
oo.createAnnotation(syn);

%% Segments
oo.setAnnoToken(uploadToken);
oo.setAnnoChannel('neurons');
for i = 1:length(s)
    i
    S = RAMONSegment;
    S.setId(s(i).id);
    S.setName(s(i).name);
    S.setNeuron(s(i).neuron);
    S.setClass(s(i).segment_class);
    S.setResolution(s(i).resolution);
    S.addDynamicMetadata('segment_subtype',s(i).segment_subtype);
    S.setSynapses(unique(s(i).synapses));

    is_spine = 0;
    if isfield(s(i),'is_spine')
        is_spine = s(i).is_spine;
    end
    S.addDynamicMetadata('is_spine', is_spine);
    S.addDynamicMetadata('spine_str',num2str(is_spine));
    S.addDynamicMetadata('synapse',num2str(unique(s(i).synapses)));
    oo.createAnnotation(S);    
end

%% Neurons

for i = 1:length(n)
    i
    N = RAMONNeuron;

    N.setId(n(i).id);
    N.setSegments(n(i).neuron_segment);
    oo.createAnnotation(N);
end

%% Synapses
oo.setAnnoChannel('synapses')

for i = 1:length(y)
    i
    Y = RAMONSynapse;
    Y.setId(y(i).id);
    Y.setResolution(y(i).resolution);
 
    Y.addSegment(y(i).presynaptic, eRAMONFlowDirection.preSynaptic);
    Y.addSegment(y(i).postsynaptic, eRAMONFlowDirection.postSynaptic);
    Y.addDynamicMetadata('psdSize',y(i).psdSize);
    Y.addDynamicMetadata('synapseLocation',y(i).synapseLocation);
    Y.addDynamicMetadata('multiSynapseBouton',y(i).multiSynapseBouton);
    Y.addDynamicMetadata('vesicleCount',y(i).vesicleCount);
    Y.addDynamicMetadata('axonSynapseType',y(i).axonSynapseType);
    Y.addDynamicMetadata('presynaptic',y(i).presynaptic);
    Y.addDynamicMetadata('postsynaptic',y(i).postsynaptic);
    
    oo.createAnnotation(Y);
end