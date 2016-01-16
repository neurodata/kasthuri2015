% FindOrphans Make tables of objects that crosss shell 0 or 1 times
%{
COPYRIGHT 2013, 2014 Jeff W. Lichtman, Narayanan (Bobby) Kasthuri, 
    Daniel Berger, and Jose A. Conchello 
%}
%{
CAVEAT EMPTOR:
    This script was writen to be used once (read writen in haste). Thus,
    it is neiter very flexible, nor well documented, nor easy to maintain.
%}
%{
PURPOSE:
    Find orphan objects in a Vast export. An object is considered an 
    orphan if part of the object is within a given volume (currently the
    so called Red Cylinder) but does not intersect the boundary of the 
    volume. 
        The script also reports objects that intersect the boundary of 
    the volume only once.

    After running listObjects, mergeList, and countShellCrossings
    read in the .mat files produced by listObjects and mergeList
    (currently RedObjList.mat) and by countShellCrossings (currently
    RedShellCorssings_01.mat).

    RedObjList.mat contains two variables
        globalPixelCount
    and
        objList.
    objList is a list of the ID numbers of the objects found in the
    red cylinder. 
        For each object, globalPixelCount has the number of pixels 
    the object has within the Red Cylinder. This array is indexed 
    by object ID number and thus has some zeros (for objects that 
    either are never within the red cylider or are in the list of 
    objects to ignore).

    RedShellCrossings_01.mat two variables:
        crossings
    and
        vastNames
    Crossings is a table of the number of times an object crosses 
    the shell of the red cylinder. This is a N x 2 array where N
    is the number of objects found in 'objList' (described above)
    The first column is the ID number of the object, the second
    column, the number of times the object crosses the shell of
    the red cylinder. 

    vastNames is a cell array indexed by the object ID number and
    contains the name of the object.
%}
%% Init
    
    clear
   
% ..RedShellMasked/RedShellCrossings_01.mat
% __Crossings info
% ..Directory where the .mat file with the crossings is
    crossDir = 'RedShellMasked'; 
% ..File name (including the directory name);
    crossName = fullfile(crossDir,'RedShellCrossings_01.mat'); 
    
% __Objects within red cylinder
% ..Directory where the files are
    cylDir = 'RedCylinderMasked';
% ..Name of the .mat file that contains the object info (IDNo, volume)
    cylName = fullname(cylDir, 'RedObjList.mat');
    
    load(cylName);
    load(crossName);
    
% ..Find the objects within the cylinder that do not touch the shell
    idx = crossings(:,2) == 0;
    noCross = crossings(idx,1);
    clear idx
    
% ..Find the objects within the cylinder that touch the shell once
    idx = crossings(:,2) == 1;
    oneCross = crossings(idx,1);
    clear idx

% __Write the tables to a files

% __zero crossings (true orphans?)
    outnm = 'Orphans.csv';
    outfl = fopen(outnm, 'w');
    if outfl == -1
       error('Unable to open ''%s'' for writing', outnm);
    end
    
% __Write zero crossings
% ..Write a header
    fprintf(outfl', 'Objects with zero crossings\n');
    fprintf(outfl, 'ID No, Name, volume\n');
    Nzero = numel(noCross);
    for k = 1:Nzero
        id   = noCross(k);
        name = vastNames{id};
        vol  = globalPixelCount(id);
        fprintf(outfl, '%d, %s, %d\n', id, name, vol);
    end
    fclose(outfl);
    
    
% __Write one crossing
    outnm = 'oneCrossing.csv';
    outfl = fopen(outnm, 'w');
    if outfl == -1
       error('Unable to open ''%s'' for writing', outnm);
    end
    
% __Write single crossing
% ..Write a header
    fprintf(outfl', 'Objects that cross once\n');
    fprintf(outfl, 'ID No, Name, volume\n');
    nOne = numel(oneCross);
    for k = 1:nOne
        id   = oneCross(k);
        name = vastNames{id};
        vol  = globalPixelCount(id);
        fprintf(outfl, '%d, %s, %d\n', id, name, vol);
    end
    fclose(outfl);
    
