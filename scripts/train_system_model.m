%TRAIN SYSTEM MODEL Frame-based distance map between two audio files
%
% This function checks the existence of a cached model and either 
% loads it or generates a new one, based on the specified audio 
% preprocessing and generation method structures defined in config. Newly 
% generated models are saved on disk.

function [model, test_data_sys] = train_system_model(filepath,modelname,testfilelist, method, cached_test_data)

%disp(testfilelist)

if exist(modelname, 'file') ||  exist([modelname,'.mat'], 'file')
%    if (DEBUGGING==1)
    disp(['loading model from ', modelname]);
%    end
    model=parload(modelname);
    test_data_sys=cached_test_data;

else
    if cached_test_data==0
        disp(['collecting training data for method ',method.analysis.name]);
        % Construct feature vectors from training data:
        
        [testpath,testfilebasename,~]=fileparts( testfilelist{1} );
        systemcode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');
        
        audio=method.preprocessing.function([filepath,testfilelist{1}], method.preprocessing, [systemcode,testfilebasename]);       
        featstruct = method.analysis.analysisfunction(audio, method.analysis, [systemcode,testfilebasename]);

        %size_of_features=size(featstruct.features)
        %max_speech_frames=max(featstruct.speech_frames)
        
        test_data_sys=featstruct.features(featstruct.speech_frames,:);
        
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
    
    model=method.modelling.trainfunction(test_data_sys,method.modelling);
    
    
    % Use a separate saving function to write the gmm to disk
    % inside a parallel loop
    parsave(modelname, model);
end