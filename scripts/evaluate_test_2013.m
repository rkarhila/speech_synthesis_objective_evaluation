%
% Evaluate our tests2013 sets for 2013
%

local_conf

   
tests2013={ ...
    struct( ...  
        'name',                  'EH1_similarity',...
        'objective_resultfile',  'results/2013/2013_EH1_objective_results_sim', ......
        'testfilelist',          'tests/2013/2013_EH1_sim.test.scp',...
        'reffilelist',           'tests/2013/2013_EH1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2013/2013_EH1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2013/significancematrix_2013_EH1_sim.ascii',...
        'systems',               'CFHIKLMNP', ...
        'systemtypes',           'hhhhccccu', ...
        'sentencesperspeaker',    11, ...
	'testtype',              'sim', ...
        'language',              'english', ...
        'speaker',               'voice_forge', ...
        'scores',                [], ...
        'results',                []), ... 
    struct( ...  
        'name',                  'EH1_naturalness',...
        'objective_resultfile',  'results/2013/2013_EH1_objective_results_nat', ......
        'testfilelist',          'tests/2013/2013_EH1_nat.test.scp',...
        'reffilelist',           'tests/2013/2013_EH1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2013/2013_EH1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2013/significancematrix_2013_EH1_nat.ascii',...
        'systems',               'CFHIKLMNP', ...
        'systemtypes',           'hhhhccccu', ...
        'sentencesperspeaker',    33, ...
	'testtype',              'nat', ...
        'language',              'english', ...
        'speaker',               'voice_forge', ...
        'scores',                [], ...
        'results',                []), ... 
    struct( ...       
        'name',                  'EH2_similarity',...
        'objective_resultfile',  'results/2013/2013_EH2_objective_results_sim', ......
        'testfilelist',          'tests/2013/2013_EH2_sim.test.scp',...
        'reffilelist',           'tests/2013/2013_EH2_sim.ref.scp',...
        'subjective_resultfile', 'tests/2013/2013_EH2_sim_mean.ascii',...
        'opinionmatrix',         'tests/2013/significancematrix_2013_EH2_sim.ascii',...
        'systems',               'BCDEFGHIJKLMNO', ...
        'systemtypes',           'chcchhhhccccch', ...
        'sentencesperspeaker',    14, ...
	'testtype',              'sim', ...
        'language',              'english', ...
        'speaker',               'voice_forge', ...
        'scores',                [], ...
        'results',                []), ... 
    struct( ...  
        'name',                  'EH2_naturalness',...
        'objective_resultfile',  'results/2013/2013_EH2_objective_results_nat', ......
        'testfilelist',          'tests/2013/2013_EH2_nat.test.scp',...
        'reffilelist',           'tests/2013/2013_EH2_nat.ref.scp',...
        'subjective_resultfile', 'tests/2013/2013_EH2_nat_mean.ascii',...
        'opinionmatrix',         'tests/2013/significancematrix_2013_EH2_nat.ascii',...
        'systems',               'BCDEFGHIJKLMNO', ...
        'systemtypes',           'chcchhhhccccch', ...
        'sentencesperspeaker',    30, ...
	'testtype',              'nat', ...
        'language',              'english', ...
        'speaker',               'voice_forge', ...
        'scores',                [], ...
        'results',                []) ...                     
      };


    

for n=1:length(tests2013)

    [scores,results] = run_individual_test(tests2013{n});

    tests2013{n}.scores=scores;
    tests2013{n}.results=results;

end


