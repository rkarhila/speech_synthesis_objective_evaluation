%GET_DIST_MAP Frame-based distance map between two audio files
%
% This function checks the existence of a cached distance map and either 
% loads it or generates a new one, based on the specified audio 
% preprocessing and generation method structures defined in config. Newly 
% generated distance maps are saved on disk.

function [distmap] = get_dist_map(filepath,mappath,reffilename,testfilename,preprocessing, method, cachedir)


    [testpath,testfilebasename,~]=fileparts( testfilename );
    systemcode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');

    [refpath,reffilebasename,~]=fileparts( reffilename );
    refcode=regexprep( refpath, '[^a-zA-Z0-9-_]', '_'); 
    
    mapmethod=[preprocessing.name,'_',method.name];
    mapname=[mappath,systemcode,testfilebasename,'_',mapmethod,'.map'];
    
    if exist(mapname, 'file') ||  exist([mapname,'.mat'], 'file')
        distmap=parload(mapname);
    else
        ref_audio=preprocessing.function([filepath,reffilename], preprocessing, [cachedir,systemcode,reffilename]);
        ref_feat = method.analysisfunction(ref_audio, method, [cachedir, refcode,reffilebasename]);
     
        test_audio=preprocessing.function([filepath,testfilename], preprocessing, [cachedir,systemcode,testfilename]);
        test_feat = method.analysisfunction(test_audio, method, [cachedir, systemcode,testfilebasename]);

        distmap = method.distancefunction(test_feat.features,ref_feat.features,method);
        % Use a separate saving function to write the map to disk 
        % inside a parallel loop
        % parsave(mapname, distmap);        
    end       