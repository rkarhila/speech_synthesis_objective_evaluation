%TRAIN SYSTEM MODEL Frame-based distance map between two audio files
%
% This function checks the existence of a cached model and either 
% loads it or generates a new one, based on the specified audio 
% preprocessing and generation method structures defined in config. Newly 
% generated models are saved on disk.

function [model, test_data_sys] = train_system_model(filepath,modelname,testfilelist, method, cached_test_data)


if exist(modelname, 'file') ||  exist([modelname,'.mat'], 'file')
    disp(['loading model from ', modelname]);
    model=parload(modelname);
    test_data_sys=cached_test_data;

else
    % Check if we have cached data in memory:
    if cached_test_data==0
        % When not, construct feature vectors from training data for the system:
        disp(['collecting training data for method ',method.analysis.name]);

        [testpath,testfilebasename,~]=fileparts( testfilelist{1} );
        systemcode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');
        
        audio=method.preprocessing.function([filepath,testfilelist{1}], method.preprocessing, [systemcode,testfilebasename]);       
        featstruct = method.analysis.analysisfunction(audio, method.analysis, [systemcode,testfilebasename]);

        test_data_sys=featstruct.features(featstruct.speech_frames,:);

        
        % This for-looping is maybe not the most elegant way to do this,
        % but it works:        
        for p=2:length(testfilelist)
            
            [testpath,testfilebasename,~]=fileparts( testfilelist{p} );
            systemcode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');
            
            audio=method.preprocessing.function([filepath,testfilelist{1}], method.preprocessing, [systemcode,testfilebasename]);
            featstruct = method.analysis.analysisfunction(audio, method.analysis, [ systemcode,testfilebasename ]);           
            
            test_data_sys=[test_data_sys; featstruct.features(featstruct.speech_frames,:)];
        end               
    else
         test_data_sys=cached_test_data;
    end
    
    % Call the training function specified in the test config:
    
    disp(['Training ',method.modelling.name]);
    model=method.modelling.trainfunction(test_data_sys,method.modelling);
    
    % Use a separate saving function to write the model to disk
    % inside a parallel loop
    parsave(modelname, model);
end