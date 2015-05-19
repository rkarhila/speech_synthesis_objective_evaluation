function [distortion_results_all, gmm_results_all, pesq_results_all , runtime]=obj_evaluation(filepath, reference_sent_list, test_sent_list)

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

% Make a list of file pair distances, initialise to zero:

%
% Initialise the result arrays 
%

gmm_results_all=zeros(length(testfilelist), length(gauss_tests));
distortion_results_all=zeros(length(testfilelist),length(dist_tests));
pesq_resuls_all=[];




%n=length(testfilelist);



tic





%%%
%%%%
%%%%%  First: Non-invasive measures:
%%%%%%
%%%%%%%

par_gaussians=cell(length(systems),1);

disp('Train or load GMMs');

% (use parallel for if available)
parfor i=1:length(systems)
      
    par_gaussians{i}=cell(length(gauss_tests),1);
    
    % For the Gaussian evaluation, we need to train the Gaussians for
    % The new system:

    %par_gaussians{i}=cell(length(gausscomps{1})+length(gausscomps{2}),length(gauss_types),length(gaussmethods))

    % make train datasets using the various feature extraction methods
    % specified in gaussmethods:

    oldspecmethod=0;
    olddistmethod=0;
    
    for y=1:length(gauss_tests)

        % Only construct the training feature vectors if the Gaussians
        % have not been generated yet
        test_data_sys=0;

        %spec_and_distmethod=gaussmethods{y};
        %specmethod=spec_and_distmethod{1};
        %distmethod=spec_and_distmethod{2};

        spec_and_distmethod=gauss_tests{y}.feature;
        specmethod = spec_and_distmethod{1};
        distmethod = spec_and_distmethod{2};
        
        % Some not-so-clever caching of features:
        if (~strcmp(oldspecmethod,specmethod) || ~strcmp(olddistmethod,distmethod))
            test_data_sys==0;
        end
        
        num_components=gauss_tests{y}.num_comps;
        cov_type=gauss_tests{y}.cov_type;

        gaussname=[gmdirectory,systems(i),testfilename,'_',specmethod,'-',distmethod,'_',num2str(num_components),'_',cov_type,'.gm'];

        % train models if not done already

        if exist(gaussname, 'file') ||  exist([gaussname,'.mat'], 'file')
            if (DEBUGGING==1)
                disp(['loading gmm from ', gaussname]);
            end
            gmm_model_set=parload(gaussname);
        else
            % If the GMM has not been computed already, gather the data (if not done already):
            if test_data_sys==0
                disp(['collecting training data for gmm ',systems(i)]);
                % Construct feature vectors from training data:

                featstruct=calculate_feas([filepath,testfilelist{(i-1)*filespersystem+1}], specmethod, distmethod,usevad,1);
                test_data_sys=featstruct.features(featstruct.speech_frames,:);
                %test_data_sys=[deltabase, deltas(deltabase,3), deltas(deltabase,5)];

                for p=2:filespersystem
                    featstruct=calculate_feas([filepath,testfilelist{(i-1)*filespersystem+p}], specmethod, distmethod,usevad,1);                             
                    test_data_sys=[test_data_sys; featstruct.features(featstruct.speech_frames,:)];

                end                    
                parsave(['/tmp/matlabdump_',systems(i)], test_data_sys);
            end

            disp(['train ',cov_type,' covariance gmm system ', systems(i) ,', ',num2str(num_components)]);

            tries=0
            while tries < gauss_retr{1}
                try
                    if cov_type=='diag'
                        gmm_model_set=gmmb_em_d(test_data_sys,'components',num_components);
                        disp(['Done in ',num2str(tries),' tries! System: ', systems(i), ' ', cov_type, ' covariance, ', num2str(num_components), ' components']);
                        tries=gauss_retr{1};
                    else
                        gmm_model_set=gmmb_em(test_data_sys,'components',num_components);                       
                        disp(['Done in ',num2str(tries),' tries! System: ', systems(i), ' ', cov_type, ' covariance, ', num2str(num_components), ' components']);                               
                        tries=gauss_retr{1};
                    end
                catch me
                    tries=tries+1;
                    disp(['Retrying ',num2str(tries),' tries! System: ', systems(i), ' ', cov_type, ' covariance, ', num2str(num_components), ' components']); 
                    if tries==gauss_retr{1}
                        error(['Singular gaussian! System: ', systems(i), ' ', cov_type, ' covariance, ', num2str(num_components), ' components']);
                    end
                end
            end

            disp(['-done gmm system ', systems(i) ,', ',num2str(num_components)]);

            % Use a separate saving function to write the gmm to disk
            % inside a parallel loop
            parsave(gaussname, gmm_model_set);
        end
        %disp(['setting par_gaussians{',num2str(i),',',num2str(y),'}']);% from ', gaussname ]);
        par_gaussians{i}{y}=gmm_model_set;

    end
    
    % Make sure not to leave the old features hanging around:
    test_data_sys=0;

end

%%%
%%%%
%%%%%  Continuing: Invasive measures:
%%%%%%
%%%%%%%
%%%%%% Calculate likelihood scores between ref gm model and the test sentence:
%%%%%
%%%%
%%%

disp('Evaluate the GMMs')

% Initialise the list of sentencepair distances:


parfor y=1:length(gauss_tests)

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



%%%
%%%%
%%%%%  
%%%%%%  
%%%%%%%   Invasive measures
%%%%%% 
%%%%%
%%%%
%%%


parfor i=1:length(testfilelist)

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

    for y=1:length(dist_tests)

        spec_and_distmethod=dist_tests{y}.map_feature;
        specmethod=spec_and_distmethod{1};
        distmethod=spec_and_distmethod{2};   

        %spec_and_distmethod=mapmethods{y};
        %specmethod=spec_and_distmethod{1};
        %distmethod=spec_and_distmethod{2};
        mapmethod=[specmethod,'_',distmethod];
        
        mapname=[mapdirectory,speakercode,testfilename,'_',mapmethod,'_norm.map'];
        
        if exist(mapname, 'file') ||  exist([mapname,'.mat'], 'file')
            distmap=parload(mapname);
            distmaps.(mapmethod)=distmap;
        else
            ref_feat=calculate_feas([filepath,reffilelist{i}], specmethod, distmethod,usevad, 0);
            test_feat=calculate_feas([filepath,testfilelist{i}], specmethod,distmethod,usevad, 0);

            distmap=make_dist_map(test_feat.features,ref_feat.features, distmethod);
            distmaps.(mapmethod)=distmap;

            % Use a separate saving function to write the map to disk 
            % inside a parallel loop
            parsave(mapname, distmap);        
        end          
    end
    
    %step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1];
    %step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1;1 2 sqrt(2)];    
    step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1;1 2 sqrt(2);2 1 sqrt(2);1 3 2; 3 1 2];
    %step_matrix=[1 1 1.0;0 1 1.0;1 0 1.0];


    distres=zeros(length(dist_tests),1);
  
    % Do DTW in the distance map:
%    for z=1:length(mapmethods)
    for y=1:length(dist_tests)

        spec_and_distmethod=dist_tests{y}.map_feature;
        specmethod=spec_and_distmethod{1};
        distmethod=spec_and_distmethod{2};   

        mapmethod=[specmethod,'_',distmethod];

        [pathp,pathq,min_cost_matrix,cost_on_best_path] = ...
            dpfast(distmaps.(mapmethod),step_matrix,1);      
        
        fullsentpathp=pathp;
        fullsentpathq=pathq;

        spec_and_distmethod=dist_tests{y}.path_feature;
        specmethod=spec_and_distmethod{1};
        distmethod=spec_and_distmethod{2};   

        pathmethod=[specmethod,'_',distmethod];
        
        pathmap=distmaps.(pathmethod);
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

%%%
%%%%
%%%%%  
%%%%%%  
%%%%%%%   PESQ
%%%%%% 
%%%%%
%%%%
%%%


if USE_PESQ == 1;
    %
    % Initialise the result array for PESQ:
    %
    pesq_results_all=zeros(length(testfilelist),length(pesq_tests));

    parfor i=1:length(testfilelist)    

        pesqref=prepare_audio([filepath,reffilelist{i}],'use_vad',usevad);
        pesqtest=prepare_audio([filepath,testfilelist{i}],'use_vad',usevad);

        scores_nb = pesqbin( pesqref, pesqtest, 16000, 'nb' );
        scores_wb = pesqbin( pesqref, pesqtest, 16000, 'wb' );

        pesq_results_all(i,:) =  pesq_results_all(i,:) + [  5 - scores_nb(1), 5 - scores_nb(2), 5 - scores_wb  ];

    end

end


runtime=toc;


   

    
    