
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

%% Parsing segmentation

% Get all unique IDs
% Use IDs from spreadsheet to be sure all core objects are correct; augment
% with manually curated labels (below)
% Add spines from both places
% Add parents from spreadsheet as appropriate 
% - all axons and dendrites are "neurons"
% - anything not an axon or dendrite or spine in sheet will need to use
% parent lookup
% Merge those together

% Upload segments and neurons

% Do claims


% synapses are a thing - match closest as possible
% then remaining are just hanging out


% Question:  bouton labels 
%- other synapses, other out of 3 cylinder volume
% missing objects

%% Parsing Metadata

% Mitochondria and Vesicles have generic metadata, so should all be the
% same

%% Segment Metadata 

%x = 0.5% of the data in cylinders

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