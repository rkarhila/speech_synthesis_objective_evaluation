function [ distlist, runtime, testlist ]=obj_evaluation(filepath, reference_sent_list, ...
    test_sent_list, mapmethods, gaussmethods, gausscomps, filespersystem)

local_conf
mapdirectory=LOCAL_MAPDIR;
gmdirectory=LOCAL_MIXTUREMODELDIR;

monitoring=0;
figuring=0;

usevad=1;
pesq_scorecount=3;

% So, we have list of reference files and a list of test files.
% Let's assume that they all exist and behave well

reffilelist = textread(reference_sent_list,'%s' );
testfilelist = textread(test_sent_list,'%s' );

if ne(length(testfilelist), length(testfilelist))
    disp('Filelists are different size, this won`t end well');
end


% How many tests do we do?

testcount=length(mapmethods)^2 + length(gaussmethods)*(length(gausscomps{1}) + length(gausscomps{2})) + pesq_scorecount;

% Make a list of file pair distances, initialise to zero:

testlist=cell(testcount,1);

% In an extremely non-elegant way, let's give some names to the
% distance methods we will:

ind=1;
for y=1:length(mapmethods)

     spec_and_distmethod=mapmethods{y};
     mapspec=spec_and_distmethod{1};
     mapdist=spec_and_distmethod{2};
     
     for z=1:length(mapmethods) 

       spec_and_distmethod=mapmethods{z};
       pathspec=spec_and_distmethod{1};
       pathdist=spec_and_distmethod{2}; 
       
       testlist{ind} = ...
           ['map: ',mapspec,'-',mapdist,', path:',pathspec,'-',pathdist];
       ind=ind+1;
     end   
end
for y=1:length(gaussmethods)
     spec_and_distmethod=gaussmethods{y};
     featspec=spec_and_distmethod{1};
     featdist=spec_and_distmethod{2};
     for j0=1:length(gausstypes)
         for z=1:length(gausscomps{j0})
            testlist{ind} =...
                ['feat: ',featspec,'-',featdist,', ',gausstypes{j0},' covariance, gausscomp:',num2str(gausscomps{j0}(z))];
            ind=ind+1;
         end
     end
end

testlist{ind}= 'PESQ Narrowband MOS';
ind=ind+1;
testlist{ind}= 'PESQ Narrowband MOS LQ0';
ind=ind+1;
testlist{ind}= 'PESQ Wideband MOS LQ0';

disp(testlist)


% Initialise the list of sentencepair distances:
distlist=zeros(length(testfilelist),testcount);

n=length(testfilelist)


% Do we monitor the progress somehow? We probably shouldn't, but just in
% case:
if monitoring==1;
    WaitBar = waitbar(0,'Initializing waitbar...');
else
    WaitBar = NaN;
end

tic



% Loop over file pairs:
% (use parallel for if available)

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

par_gaussians=cell(length(systems),1); %length(gausscomps),length(gaussmethods))


parfor i=1:length(systems)
            

    % For the Gaussian evaluation, we need to train the Gaussians for
    % The new system:

    par_gaussians{i}=cell(length(gausscomps{1})+length(gausscomps{2}),length(gausstypes),length(gaussmethods))

    % make train datasets using the various feature extraction methods
    % specified in gaussmethods:
    for y=1:length(gaussmethods)

        % Only construct the training feature vectors if the Gaussians
        % have not been generated yet
        test_data_sys=0;

        spec_and_distmethod=gaussmethods{y};
        specmethod=spec_and_distmethod{1};
        distmethod=spec_and_distmethod{2};

        % train models if not done already
        
        for j0=1:length(gausstypes)
            
            for j=1:length(gausscomps{j0})

                num_components=gausscomps{j0}(j);

                gaussname=[gmdirectory,systems(i),testfilename,'_',specmethod,'-',distmethod,'_',num2str(num_components),'_',gausstypes{j0},'.gm'];
                
                if exist(gaussname, 'file') ||  exist([gaussname,'.mat'], 'file')
                    disp(['loading gmm from ', gaussname]);
                    gmm_model_set=parload(gaussname);
                else
                    % If the GMM has not been computed already, gather the data (if not done already):
                    if test_data_sys==0
                        disp(['collecting training data for gmm ',systems(i)]);
                        % Construct feature vectors from training data:

                        featstruct=calculate_feas([filepath,testfilelist{(i-1)*filespersystem+1}], specmethod, distmethod,usevad);
                        test_data_sys=featstruct.features(featstruct.speech_frames,:);

                        for p=2:filespersystem
                            featstruct=calculate_feas([filepath,testfilelist{(i-1)*filespersystem+p}], specmethod, distmethod,usevad);                             
                            test_data_sys=[test_data_sys; featstruct.features(featstruct.speech_frames,:)];
                        end                    
                        parsave(['/tmp/matlabdump_',systems(i)], test_data_sys);
                    end
                    
                    disp(['train ',gausstypes{j0},' covariance gmm system ', systems(i) ,', ',num2str(num_components)]);

                    tries=0
                    while tries<gauss_retries
                        try
                            if gausstypes{j0}=='diag'
                                gmm_model_set=gmmb_em_d(test_data_sys,'components',num_components);
                                tries=5;
                            else
                                gmm_model_set=gmmb_em(test_data_sys,'components',num_components);                       
                                tries=5;
                            end
                        catch me
                            tries=tries+1;
                            if tries==gauss_retries
                                error('foo!');
                            end
                        end
                    end
                        
                    disp(['-done gmm system ', systems(i) ,', ',num2str(num_components)]);

                    % Use a separate saving function to write the gmm to disk
                    % inside a parallel loop
                    parsave(gaussname, gmm_model_set);
                end
                disp(['setting par_gaussians{',num2str(i),'}{',num2str(y),',',num2str(j),'}']);% from ', gaussname ]);
                par_gaussians{i}{y,j0,j}=gmm_model_set;

            end
        end
        % Make sure not to leave the old features hanging around:
        test_data_sys=0;
    end
    
    
end


parfor i=1:length(testfilelist)

    % Examine the file we will test:
    % Extract system code to save in the right place
    % (and for reporting?)
    
    [testpath,testfilename,testfilext]=fileparts(testfilelist{i});
    speakercode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');
    systemcode=speakercode(1);
    disp(testfilename);

    % Compute distance maps between test and ref sample;
    % Load from disk if we have already computed it.
    distmaps=cell(length(mapmethods));
      
    for y=1:length(mapmethods)
        spec_and_distmethod=mapmethods{y};
        specmethod=spec_and_distmethod{1};
        distmethod=spec_and_distmethod{2};
        mapmethod=[specmethod,'_',distmethod];
        
        mapname=[mapdirectory,speakercode,testfilename,'_',mapmethod,'_norm.map'];
        
        if exist(mapname, 'file') ||  exist([mapname,'.mat'], 'file')
            distmaps{y}=parload(mapname);
        else
            ref_feat=calculate_feas([filepath,reffilelist{i}], specmethod, distmethod,usevad);
            test_feat=calculate_feas([filepath,testfilelist{i}], specmethod,distmethod,usevad);
            
            [distmap]=make_dist_map(test_feat.features,ref_feat.features, distmethod);
            
            distmaps{y}=distmap;
            % Use a separate saving function to write the map to disk 
            % inside a parallel loop
            parsave(mapname, distmap);
        
        end          
    end

    result=zeros(1,testcount);    
    
    %step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1];
    %step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1;1 2 sqrt(2)];    
    step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1;1 2 sqrt(2);2 1 sqrt(2);1 3 2; 3 1 2];
    %step_matrix=[1 1 1.0;0 1 1.0;1 0 1.0];

    
    % Do DTW in the distance map:
    for z=1:length(mapmethods)

       [pathp,pathq,min_cost_matrix,cost_on_best_path] = ...
            dpfast(distmaps{z},step_matrix,1);      
        
        fullsentpathp=pathp;
        fullsentpathq=pathq;

        for y=1:length(mapmethods)
            thiscost3=0;
            for j=1:length(fullsentpathp)
                thiscost3=thiscost3+distmaps{y}(fullsentpathp(j),fullsentpathq(j));
            end
            thiscost3 = thiscost3/length(fullsentpathp);

            result( (z-1)*(length(mapmethods)) + y) = thiscost3;
            
        end
        
    end
    
    
    % Calculate likelihood scores between ref gm model and the test sentence:
    
    for y=1:length(gaussmethods)
                               
       spec_and_distmethod=gaussmethods{y};
       specmethod=spec_and_distmethod{1};
       distmethod=spec_and_distmethod{2};   

       test_feat=calculate_feas([filepath,testfilelist{i}], specmethod, distmethod,usevad);

       for j0=1:length(gausstypes)

           for j=1:length(gausscomps{j0})  

                % Again this line? Hope it is cached...
                ref_feat=calculate_feas([filepath,reffilelist{i}], specmethod, distmethod,usevad);

                %disp(['result index ',num2str(length(mapmethods)^2 + (y-1)*length(gausscomps) + j), ' of ' num2str(length(result))]);
                %disp(['gaussian ', num2str((y-1)*length(gausscomps)+j),' of ',num2str(length(par_gaussians)  ) ]);
                %par_gaussians{ (y-1)*length(gausscomps)+j }

                gmmres= -sum(log(gmmb_pdf(ref_feat.features(ref_feat.speech_frames,:), par_gaussians{find(systems==systemcode)}{y,j0,j})+exp(-700)))/size(test_feat,1);

                if isnan(gmmres)
                    disp(gmmb_pdf(test_feat, par_gaussians{find(systems==systemcode)}{y,j0,j}))
                end
                result( length(mapmethods)^2 + (y-1)*length(gausscomps{j0}) + j) = gmmres;


           end
       end
    end
    
    
    pesqref=prepare_audio([filepath,reffilelist{i}],'use_vad',usevad);
    pesqtest=prepare_audio([filepath,testfilelist{i}],'use_vad',usevad);
    
    scores_nb = pesqbin( pesqref, pesqtest, 16000, 'nb' );
    scores_wb = pesqbin( pesqref, pesqtest, 16000, 'wb' );
    
    result( length(mapmethods)^2 + length(gaussmethods)*length(gausscomps{j0}) + 1) = 5 - scores_nb(1)
    result( length(mapmethods)^2 + length(gaussmethods)*length(gausscomps{j0}) + 2) = 5 - scores_nb(2)
    result( length(mapmethods)^2 + length(gaussmethods)*length(gausscomps{j0}) + 3) = 5 - scores_wb
    
    fprintf('%0.1f\t', result);
    disp('\n');
    distlist(i,:) = distlist(i,:) + result;

    
    if monitoring==1;
       
        %Here's the progress bar code
        t=toc;
        Perc=i/n;
        Trem=t/Perc-t; %Calculate the time remaining
        Hrs=floor(Trem/3600);Min=floor((Trem-Hrs*3600)/60);
        waitbar(Perc,WaitBar,[sprintf('%0.1f',Perc*100) '%, '...
            sprintf('%03.0f',Hrs) ':'...
            sprintf('%02.0f',Min) ':'...
            sprintf('%02.0f',rem(Trem,60)) ' remaining']);
        
    end
    
end

if monitoring==1;
    close(WaitBar);
end

runtime=toc;


    
    
    
    