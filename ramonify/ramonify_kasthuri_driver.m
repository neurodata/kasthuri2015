% ramonify_kasthuri_driver
% written in a modular fashion to simplify things
run('~/code/cajal-master/cajal.m')
uploadToken = 'kasthuri2015_ramon_v4';

ramonify_get_data
% input is token, self contained (bc lack of deps)
% output is uploaded RAMONData
ramonify_vesicle_mito


%input is synapse data, output is synOut matrix
ramonify_synapses_paint

% input is paint and spreadsheet and vast scripts
ramonify_neurons
% output is neurons and synapses ready to upload

% associate neurons and synapses
ramonify_associate_synapses_neurons

% upload!
ramonify_upload