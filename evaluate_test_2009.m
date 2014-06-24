%
% Evaluate our tests sets for 2009 
%

local_conf

mapmethods={ {'fft','snr'},...
             {'straight','snr'},...
             {'fft','mcd'}, ...
             {'straight','mcd'}, ...
             {'llr','llr'}};

gaussmethods= { { 'straight', 'log-mel' }, ...
                { 'fft', 'log-mel'} };

gausscomps=[10,30,50];        

% How many tests do we do?

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

tests2009={ ...
    struct( ...  
        'name',                  'EH1_similarity',...
        'objective_resultfile',  'tests/2009/2009_EH1_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_EH1_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_EH1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_EH1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_EH1_sim.ascii',...
        'systems',               'BCDEHIJKLMOPQRSTW', ...
        'sentencesperspeaker',    18, ...
          'scores',                [], ...
          'results',                []), ... 
    struct( ...  
        'name',                  'EH1_naturalness',...
        'objective_resultfile',  'tests/2009/2009_EH1_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_EH1_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_EH1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_EH1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_EH1_nat.ascii',...
        'systems',               'BCDEHIJKLMOPQRSTW', ...
        'sentencesperspeaker',    39, ...
          'scores',                [], ...
          'results',                []), ... 
    struct( ...  
        'name',                  'ES1_similarity',...
        'objective_resultfile',  'tests/2009/2009_ES1_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_ES1_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_ES1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_ES1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_ES1_sim.ascii',...
        'systems',               'DHJLPSW', ...
        'sentencesperspeaker',    16, ...
          'scores',                [], ...
          'results',                []), ...     
    struct( ...  
        'name',                  'ES1_naturalness',...
        'objective_resultfile',  'tests/2009/2009_ES1_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_ES1_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_ES1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_ES1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_ES1_nat.ascii',...        
        'systems',               'DHJLPSW', ...
        'sentencesperspeaker',    16, ...
          'scores',                [], ...
          'results',                []), ...     
    struct( ...  
        'name',                  'MH__similarity',...
        'objective_resultfile',  'tests/2009/2009_MH_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_MH_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_MH_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MH_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MH_sim.ascii',...        
        'systems',               'CDGILMNRVW', ...
        'sentencesperspeaker',    12, ...
          'scores',                [], ...
          'results',                []), ...     
    struct( ...
        'name',                  'MH__naturalness',...
        'objective_resultfile',  'tests/2009/2009_MH_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_MH_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_MH_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MH_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MH_nat.ascii',...                
        'systems',               'CDGILMNRVW', ...
        'sentencesperspeaker',    24, ...
          'scores',                [], ...
          'results',                []), ...     
    struct( ...
        'name',                  'MS1_similarity',...
        'objective_resultfile',  'tests/2009/2009_MS1_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_MS1_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_MS1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MS1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MS1_sim.ascii',...
        'systems',               'DLMRVW', ...
        'sentencesperspeaker',    13, ...
          'scores',                [], ...
          'results',                []), ...     
    struct( ...
        'name',                  'MS1_naturalness',...
        'objective_resultfile',  'tests/2009/2009_MS1_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_MS1_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_MS1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MS1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MS1_nat.ascii',...
        'systems',               'DLMRVW', ...
        'sentencesperspeaker',    14, ...
          'scores',                [], ...
          'results',                []) ...         
%    struct( ...
%        'name',                  'MS2_naturalness',...
%        'objective_resultfile',  '--devel/2009_EH1_objective_results_nat',...
%        'testfilelist',          '--devel/2009_EH1_nat.ref.scp',...
%        'reffilelist',           '--devel/2009_EH1_nat.test.scp',...
%        'subjective_resultfile', '--tests/2009_subjective_eval_nat_means_only_num.txt',...
%        'opinionmatrix',         'tests/significancematrix_2009_MS2_nat.ascii',...
%        'systems',               'CDFLNRVW', ...
%        'sentencesperspeaker',    19, ...
%          'scores',                [], ...
%          'results',                []), ... 
      };


    
for n=1:length(tests2009)
    if exist(tests2009{n}.objective_resultfile, 'file') == 0;   
        [ objdata, test_runtime, testlist] = obj_evaluation(BLIZZARD2009_RESULTDIR, tests2009{n}.reffilelist,tests2009{n}.testfilelist,...
            mapmethods,  gaussmethods, gausscomps, tests2009{n}.sentencesperspeaker);
        save(tests2009{n}.objective_resultfile, 'objdata','-ascii');
        tests2009{n}.results=objdata;
    else      
        disp(['Loading results from ',tests2009{n}.objective_resultfile])
        tests2009{n}.results=load(tests2009{n}.objective_resultfile);
        
    end
    
    tests2009{n}.scores=evaluate_wilcoxon(tests2009{n}.results, load(tests2009{n}.subjective_resultfile), load(tests2009{n}.opinionmatrix), ...
                               tests2009{n}.systems, 0);
end

