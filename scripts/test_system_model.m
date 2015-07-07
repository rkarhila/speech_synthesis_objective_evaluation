%TEST SYSTEM MODEL 
%
% This function tests a model on a set of data and returns some kind of
% number related to it.

function [result, ref_data_sys] = test_system_model(filepath, reffile,model, method, cached_ref_data, cachedir)

%disp(testfilelist)

    [refpath,reffilebasename,~]=fileparts( reffile );
    systemcode=regexprep( refpath, '[^a-zA-Z0-9-_]', '_');
        

    if cached_ref_data==0
        disp(['Extracting testing data for method ',method.analysis.name, '-',method.modelling.name ,' file ',reffilebasename]);
        % Construct feature vectors from ref data:
        audio=method.preprocessing.function([filepath, reffile], method.preprocessing, [systemcode,reffilebasename]);       
        featstruct = method.analysis.analysisfunction(audio, method.analysis, [cachedir, systemcode,reffilebasename]);

        ref_data_sys=featstruct.features(featstruct.speech_frames,:);
                     
    else
         ref_data_sys=cached_ref_data;
    end

    try
        result=method.modelling.testfunction(model,ref_data_sys,method.modelling);
    catch ME
        parsave('/tmp/data_dump', ref_data_sys);
        parsave('/tmp/model_dump', model);
        disp('saved model and data to /tmp/model_dump and /tmp/data_dump');
        rethrow(ME)
    end
    
    
end