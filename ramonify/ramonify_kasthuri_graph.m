 %% RAMONify Kasthuri
% v0.1
% W. Gray Roncal

uploadToken = 'kasthuri2015_ramon_v4'%'kasthuri2015_ramon_v1';

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
attredgeWriter(edgeList,'kasthuri_graph_v4.attredge')
csvwrite('kasthuri_graph_v4.edgelist',edgeList2)

% for now, convert to graphml using graph service - will be in ndio soon.