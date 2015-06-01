function [test_results, runtime] = evaluate_with_invasive_measures(filepath, reference_sent_list, test_sent_list )


local_conf
DEBUGGING=0;

% Assign some values to new variables so they will be
% accessible in paraller for loop:
mapdirectory=LOCAL_MAPDIR;


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
    %disp(testfilename);

    if isempty(find(systems==systemcode))
        systems=[systems;systemcode];
    end
end



filespersystem=length(reffilelist)/length(systems);







%
% Define here to make parfor happy:
%
tests=invasive_tests;

%
% Initialise the result array
%
distortion_results_all=zeros(length(testfilelist),length(tests));

tic


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

    %step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1;1 2 sqrt(2);2 1 sqrt(2);1 3 2; 3 1 2];

    distres=zeros(length(tests),1);


    for y=1:length(tests)

        test=tests{y};

        mapmethod=[test.preprocessing.name,'_',test.map_feature.name];

        if ~isfield(distmaps, mapmethod)
            distmaps.(mapmethod) = get_dist_map(filepath,mapdirectory, reffilelist{i}, testfilelist{i}, test.preprocessing, test.map_feature);
        end
        
        
        if ~isfield(test, 'step_matrix')
           error([test.name,' has no step_matrix defined']) ;
        end
        %
        % Get DTW mapping between utterances based on the above map:
        %
        [pathp,pathq,min_cost_matrix,cost_on_best_path] = ...
            dpfast(distmaps.(mapmethod),test.step_matrix,1);      
        
        fullsentpathp=pathp;
        fullsentpathq=pathq;

        %
        % Compute the mean DTW cost along the path based on 
        % another distance map:
        
        pathmethod=[test.preprocessing.name,'_',test.path_feature.name];
        mapname=[mapdirectory,speakercode,testfilename,'_',pathmethod,'.map'];
        
        if ~isfield(distmaps, pathmethod)
            distmaps.(pathmethod) = get_dist_map(filepath,mapdirectory,reffilelist{i},testfilelist{i}, test.preprocessing, test.path_feature);
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