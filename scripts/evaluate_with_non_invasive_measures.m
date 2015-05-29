function [model_results_all, runtime] = evaluate_with_non_invasive_measures(filepath, reference_sent_list, test_sent_list )


local_conf

% Assign some values to new variables so they will be
% accessible in paraller for loop:
mapdirectory=LOCAL_MAPDIR;
gmdirectory=LOCAL_MIXTUREMODELDIR;

% So, we have list of reference files and a list of test files.
% Let's assume that they all exist and behave well

reffilelist = textread(reference_sent_list,'%s' );
testfilelist = textread(test_sent_list,'%s' );

if ne(length(testfilelist), length(testfilelist))
    disp('Filelists are different size, this won`t end well');
end




systems=[];
for i=1:length(testfilelist)
    % Examine the file we will test:
    % Extract system code to save in the right place
    % (and for reporting?)
    
    [testpath,testfilename,testfilext]=fileparts(testfilelist{i});
    speakercode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');
    systemcode=speakercode(1);
    % disp(testfilename);

    if isempty(find(systems==systemcode))
        systems=[systems;systemcode];
    end
end



filespersystem=length(reffilelist)/length(systems);




% How many tests do we do?

testcount=length(testlist);





%
%
% First the models needs to be trained on the complete test data:
%
%
disp('Train or load GMMs');

par_modelsets=cell(length(systems),1);

% (use parallel for if available)
%par
for i=1:length(systems)
      
    par_modelsets{i}=cell(length(non_invasive_tests),1);
    
    % For the Gaussian evaluation, we need to train the Gaussians for
    % The new system:

    % make train datasets using the various feature extraction methods
    % specified in gaussmethods:

    old_analysis_name=0;
    test_data_sys=0;        
    
    for y=1:length(non_invasive_tests)

        % Only construct the training feature vectors if the Gaussians
        % have not been generated yet

        test=non_invasive_tests{y};
               
        % Some not-so-clever caching of features:
        if ( ~strcmp(old_analysis_name,[ test.preprocessing.name, test.analysis.name]) )
            disp('resetting feature cache');
            test_data_sys=0;
        end

        %
        % Make a cell of all the audio files for a partifcular system:
        %
        testfilenames= {testfilelist{ (i-1)*filespersystem+1 : (i)*filespersystem }};
        
        % Give some kind of identifier to the model for caching on disk:
        %
        modelname=[gmdirectory,systems(i),testfilename,'_',test.preprocessing.name,'-',test.analysis.name,'-',test.modelling.name];

        % train models if not done already
        % function [model, test_data_sys] = train_system_model(filepath,modelname,testfilenames, method, cached_test_data)
        
        disp(['train ', modelname]);
        
        [model_set, test_data_sys] = train_system_model( filepath, modelname, testfilenames, test, test_data_sys  );
        
        model_set.modelname=modelname;
        
        par_modelsets{i}{y}=model_set;
        old_analysis_name=[ test.preprocessing.name, test.analysis.name];
    end
    
    % Make sure not to leave the old features hanging around:
    test_data_sys=0;

end

%%%
%%%%
%%%%%  Continuing: Non-invasive measures:
%%%%%%
%%%%%%%
%%%%%% Calculate likelihood scores between ref gm model and the test sentence:
%%%%%
%%%%
%%%

disp('Evaluate the GMMs')


% Initialise the list of sentencepair distances:
 

%
% Make a cell of all the audio files for the reference speaker system:
% (Should be the same set for all systems!)


model_results_all=zeros(length(testfilelist), length(non_invasive_tests));

for y=1:length(non_invasive_tests)

    test=non_invasive_tests{y};
    
    modelres=zeros(length(reffilelist),1);

    for u=1:filespersystem
        ref_data_sys=0;    
        
        for i=1:length(systems)

            index=(i-1)*filespersystem+u;

            model=par_modelsets{i}{y};
            disp (['Using model {',num2str(i),'}{',num2str(y),'}: ',model.modelname] );
            
            [result, ref_data_sys] = test_system_model( filepath,reffilelist{u}, par_modelsets{i}{y}, test, ref_data_sys  );

            modelres(index)=result;
            
        end
        
    end


    
    model_results_all(:,y) =  model_results_all(:,y) + modelres;
    
end

disp(model_results_all);


runtime=toc;