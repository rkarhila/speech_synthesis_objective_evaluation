%
% Evaluate our development set 2009 EH2 
%

local_conf

mapmethods={ {'fft','snr'},...
             {'straight','snr'},...
             {'fft','mcd'}, ...
             {'straight','mcd'},...
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

dtests={ ...
    struct( ...
        'name',                  'EH2_similarity',...
        'objective_resultfile',  'devel/2009_EH2_objective_results_sim',...
        'testfilelist',          'devel/2009_EH2_sim.test.scp',...
        'reffilelist',           'devel/2009_EH2_sim.ref.scp',...
        'subjective_resultfile', 'devel/2009_EH2_sim_mean.ascii',...
        'opinionmatrix',         'blizzard_tests/significancematrix_2009_EH2_sim.ascii',...
        'systems',               'BCDEHIJKLMOPQRSTUW', ...
        'sentencesperspeaker',    19, ...
        'results',                []), ...
    struct( ...
        'name',                  'EH2_naturalness',...
        'objective_resultfile',  'devel/2009_EH2_objective_results_nat',...
        'testfilelist',          'devel/2009_EH2_nat.test.scp',...
        'reffilelist',           'devel/2009_EH2_nat.ref.scp',...
        'subjective_resultfile', 'devel/2009_EH2_sim_mean.ascii',...
        'opinionmatrix',         'blizzard_tests/significancematrix_2009_EH2_nat.ascii',...
        'systems',               'BCDEHIJKLMOPQRSTUW', ...
        'sentencesperspeaker',    19, ...
        'results',                []) ...
    };


    

    
for n=1:length(dtests)
    if exist(dtests{n}.objective_resultfile, 'file') == 0;   
        [ objdata, test_runtime, testlist ] = obj_evaluation(BLIZZARD2009_RESULTDIR, dtests{n}.reffilelist,dtests{n}.testfilelist,...
            mapmethods, gaussmethods, gausscomps, dtests{n}.sentencesperspeaker);
        save(dtests{n}.objective_resultfile, 'objdata','-ascii');                      
        dtests{n}.results=objdata;
        
        disp(testlist)
    else      
        disp(['Loading results from ',dtests{n}.objective_resultfile])
        dtests{n}.results=load(dtests{n}.objective_resultfile);
        
    end
    dtests{n}.scores=evaluate_wilcoxon(dtests{n}.results, load(dtests{n}.subjective_resultfile), load(dtests{n}.opinionmatrix), ...
                               dtests{n}.systems, 0);
end

