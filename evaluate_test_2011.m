%
% Evaluate our tests2011 sets for 2011
%

local_conf

% How many tests2011 do we do?

testcount=length(mapmethods)^2 + length(gaussmethods)*length(gausscomps);

% Make a list of file pair distances, initialise to zero:

testlist=cell(testcount,1);

ind=1
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
    
     for z=1:length(gausscomps)
        testlist{ind} =...
            ['feat: ',featspec,'-',featdist,', gausscomp:',num2str(gausscomps(z))];
        ind=ind+1;
     end
end

disp(testlist)


if (matlabpool('size') == 0)
    matlabpool
end

tests2011={ ...
    struct( ...  
        'name',                  'EH1_similarity',...
        'objective_resultfile',  'results/2011/2011_EH1_objective_results_sim',...
        'testfilelist',          'tests/2011/2011_EH1_sim.test.scp',...
        'reffilelist',           'tests/2011/2011_EH1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2011/2011_EH1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2011/significancematrix_2011_EH1_sim.ascii',...
        'systems',               'BCDEFGHIJKLM', ...
        'sentencesperspeaker',    26, ...
        'scores',                [], ...
        'results',                []), ... 
    struct( ...  
        'name',                  'EH1_naturalness',...
        'objective_resultfile',  'results/2011/2011_EH1_objective_results_nat',...
        'testfilelist',          'tests/2011/2011_EH1_nat.test.scp',...
        'reffilelist',           'tests/2011/2011_EH1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2011/2011_EH1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2011/significancematrix_2011_EH1_nat.ascii',...
        'systems',               'BCDEFGHIJKLM', ...
        'sentencesperspeaker',    26, ...
        'scores',                [], ...
        'results',                []) ...
      };


    
for n=1:length(tests2011)
    if exist(tests2011{n}.objective_resultfile, 'file') == 0;   
        [ objdata, test_runtime, testlist] = obj_evaluation(BLIZZARD2011_RESULTDIR, tests2011{n}.reffilelist,tests2011{n}.testfilelist,...
            mapmethods,  gaussmethods, gausscomps, tests2011{n}.sentencesperspeaker);
        save(tests2011{n}.objective_resultfile, 'objdata','-ascii');
        tests2011{n}.results=objdata;
    else      
        disp(['Loading results from ',tests2011{n}.objective_resultfile])
        tests2011{n}.results=load(tests2011{n}.objective_resultfile);
        
    end
    
    tests2011{n}.scores=evaluate_wilcoxon(tests2011{n}.results, load(tests2011{n}.subjective_resultfile), load(tests2011{n}.opinionmatrix), ...
                               tests2011{n}.systems, 0);
end

