function [test_results, runtime] = evaluate_with_non_invasive_measures(filepath, reference_sent_list, test_sent_list )


local_conf
DEBUGGING=0;

% Assign some values to new variables so they will be
% accessible in paraller for loop:
mapdirectory=LOCAL_MAPDIR;
gmdirectory=LOCAL_MIXTUREMODELDIR;
gauss_retr={gauss_retries};
gauss_tests=non_invasive_tests;

dist_tests=invasive_tests;
%gauss_types=gausstypes
usevad=1;

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

par_gaussians=cell(length(systems),1);

% (use parallel for if available)
%par
for i=1:length(systems)
      
    par_gaussians{i}=cell(length(gauss_tests),1);
    
    % For the Gaussian evaluation, we need to train the Gaussians for
    % The new system:

    % make train datasets using the various feature extraction methods
    % specified in gaussmethods:

    old_analysis_name=0;
    
    for y=1:length(non_invasive_tests)

        % Only construct the training feature vectors if the Gaussians
        % have not been generated yet
        test_data_sys=0;
        test=non_invasive_tests{y}
               
        % Some not-so-clever caching of features:
        if ( ~strcmp(old_analysis_name,test.name) )
            test_data_sys==0;
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
        
        [gmm_model_set, test_data_sys] = train_system_model( filepath, modelname, testfilenames, test, test_data_sys  )
        
        par_gaussians{i}{y}=gmm_model_set;

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


%par
for y=1:length(gauss_tests)

    gmmres=zeros(length(testfilelist),1);

    for u=1:filespersystem

        % somehow get these numbers to fit all test files...

        spec_and_distmethod=gauss_tests{y}.feature;
        specmethod=spec_and_distmethod{1};
        distmethod=spec_and_distmethod{2};   

        % Again this line? Hope the feature is cached...
        ref_feat=calculate_feas([filepath,reffilelist{u}], specmethod, distmethod,usevad, 1);

        for i=1:length(systems)                               

            index=(i-1)*filespersystem+u;

            %
            % Why is this normalised with the length of test_feat?
            %
            %gmmres(i)= -sum(log(gmmb_pdf(ref_feat.features(ref_feat.speech_frames,:), par_gaussians{i}{y})+exp(-700)))/size(test_feat,1);
            %
            % Let's replace with:
            gmmres(index)= -sum(log(gmmb_pdf(ref_feat.features(ref_feat.speech_frames,:), par_gaussians{i}{y})+exp(-700)))/size(ref_feat,1);

            if isnan(gmmres(i))
                disp(['NaN! ', num2str(gmmb_pdf(ref_feat, par_gaussians{i}))]);
            end
            %disp ([gauss_tests{y}.name,': ', num2str(gmmres(i))]);
            %gmmres(i);

        end

        %disp(['size(gmmres)=',num2str(size(gmmres))]);
        
        %disp(['size(gmm_results_all(:,y))',num2str(size(gmm_results_all(:,y)))]);
        
    end

    gmm_results_all(:,y) =  gmm_results_all(:,y) + gmmres; % length(mapmethods)^2 + (y-1)*length(gausscomps{j0}) + j) = gmmres;

end

disp(gmm_results_all)



%
% Initialise the result array
%
distortion_results_all=zeros(length(testfilelist),length(dist_tests));



tic



%par
for i=1:length(testfilelist)

    % Examine the file we will test:
    % Extract system code to save in the right place
    % (and for reporting?)
    
    [testpath,testfilename,testfilext]=fileparts(testfilelist{i});
    speakercode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');
    systemcode=speakercode(1);
    %disp(testfilename);

    % Compute distance maps between test and ref sample;
    % Load from disk if we have already computed it.
    distmaps=struct('init',1);

    step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1;1 2 sqrt(2);2 1 sqrt(2);1 3 2; 3 1 2];

    distres=zeros(length(dist_tests),1);


    for y=1:length(invasive_tests)

        test=invasive_tests{y};

        mapmethod=[test.preprocessing.name,'_',test.map_feature.name];

        if ~isfield(distmaps, mapmethod)
            distmaps.(mapmethod) = get_dist_map(filepath,mapdirectory, reffilelist{i}, testfilelist{i}, test.preprocessing, test.map_feature);
        end
        
        %
        % Get DTW mapping between utterances based on the above map:
        %
        [pathp,pathq,min_cost_matrix,cost_on_best_path] = ...
            dpfast(distmaps.(mapmethod),step_matrix,1);      
        
        fullsentpathp=pathp;
        fullsentpathq=pathq;

        %
        % Compute the mean DTW cost along the path based on 
        % another distance map:
        
        pathmethod=[test.preprocessing.name,'_',test.path_feature.name];
        mapname=[mapdirectory,speakercode,testfilename,'_',pathmethod,'.map'];
        
        if ~isfield(distmaps, pathmethod)
            distmaps.(pathmethod) = get_distmap(filepath,mapdirectory,reffilelist{i},testfilelist{i}, test.preprocessing, test.path_feature);
        end

       
        pathmap=distmaps.(pathmethod);

        % Traverse the path and sum the costs along it:
        pathcost=0;
        for j=1:length(fullsentpathp)
            pathcost=pathcost+pathmap(fullsentpathp(j),fullsentpathq(j));
        end
        meanpathcost = pathcost/length(fullsentpathp);

        distres(y)=meanpathcost;        
        
    end
    

    fprintf('%0.1f\t', distres);
    disp('\n');

    distortion_results_all(i,:) =  distortion_results_all(i,:) + distres';
    
end

disp(distortion_results_all)

test_results=distortion_results_all;

runtime=toc;