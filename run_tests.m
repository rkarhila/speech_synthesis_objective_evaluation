local_conf;

% Figurecounter
fc=100;

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


evaluate_test_2008;
evaluate_test_2009;
evaluate_test_2010;
evaluate_test_2011;
evaluate_test_2012;
evaluate_test_2013;


%
%
%   Similarity and naturalness for all test data.
%
%

tests={tests2008, tests2009, tests2010, tests2011, tests2012,  tests2013};

sim=tests{1}{1}.scores(:,7);
nat=tests{1}{2}.scores(:,7);

n=1;
for m=3:length(tests{n})
  if tests{n}{m}.testtype == 'nat'
      nat=[nat,tests{n}{m}.scores(:,7)];
  else
      sim=[sim,tests{n}{m}.scores(:,7)];
  end
end

for n=2:length(tests)
   for m=1:length(tests{n})
      if tests{n}{m}.testtype == 'nat'
          nat=[nat,tests{n}{m}.scores(:,7)];
      else
          sim=[sim,tests{n}{m}.scores(:,7)];
      end
   end
end

% 
% figure
% subplot(2,1,1)
% %errorbar(mean(sim'),std(sim'),'o')
% boxplot(sim')
% title('similarity')
% grid on
% subplot(2,1,2)
% %errorbar(mean(nat'),std(nat'),'o')
% boxplot(nat')
% title('naturalness')
% grid on


%
%  Difference in objective measure when making correct or incorrect guess
%
%  For all the different speakers:
%
%  Similarity            Naturalness
%  Roger: 
%  
%  2008{1,3}             2008{2,4}
%  2009{1,3}             2009{2,4}
%  2010{3}               2010{4}
%
%  Speakit:
%  2008{5}               2008{6}
%
%  WJ:
%  2009{5,7}             2009{6,8}
%
%  rjs:
%  2010{1,5,7}           2010{2,6,8}
%
%  CAS speaker:
%  2010{9,11,13}         2010{10,12,14}
%
%  Nancy:
%  2011{1}               2011{2}
%
%  Librivox speaker:
%  2012{1}               2012{2}
%
%  Voice Forge speaker:
%  2013{1,3}             2013{2,4}


%
%  All systems:
%

comparisontypeslist={ {'All systems', 1:3 }, ...
                      {'Unit selection systems only', 1}, ...
                      {'HMM-systems only',2}  };

res = { struct('simnons',{{}},'simsigs',{{}},'simmins',[],'simmaxs',[],'simspeakers',{{}}, 'simperformances', {{}},'natnons',{{}},'natsigs',{{}},'natmins',[],'natmaxs',[],'natspeakers',{{}}, 'natperformances', {{}} ), ...
        struct('simnons',{{}},'simsigs',{{}},'simmins',[],'simmaxs',[],'simspeakers',{{}}, 'simperformances', {{}},'natnons',{{}},'natsigs',{{}},'natmins',[],'natmaxs',[],'natspeakers',{{}}, 'natperformances', {{}} ), ...
        struct('simnons',{{}},'simsigs',{{}},'simmins',[],'simmaxs',[],'simspeakers',{{}}, 'simperformances', {{}},'natnons',{{}},'natsigs',{{}},'natmins',[],'natmaxs',[],'natspeakers',{{}}, 'natperformances', {{}} ) };

                  
for comparisoncount=1:3                      

    comparisontypes=comparisontypeslist{comparisoncount}{2};
    comparisonname=comparisontypeslist{comparisoncount}{1};


    n=0;
    m=0;

    for p=1:length(tests)
        for r=1:length(tests{p})
            t=tests{p}{r};

            [sigs,nons]=get_significance_distances_by_systemtype(t.results, load(t.subjective_resultfile), load(t.opinionmatrix),t.systems, t.systemtypes);

            for comparisontype=comparisontypes

                if t.testtype == 'sim'
                    n=n+1;
                    res{comparisoncount}.simnons{n}=nons{comparisontype};
                    res{comparisoncount}.simsigs{n}=sigs{comparisontype};
                    res{comparisoncount}.simspeakers{n}=t.speaker;
                else
                    m=m+1;
                    res{comparisoncount}.natnons{m}=nons{comparisontype};
                    res{comparisoncount}.natsigs{m}=sigs{comparisontype};          
                    res{comparisoncount}.natspeakers{m}=t.speaker;
                end
            end
        end
    end
    
    
end



for comparisoncount=1:3               
    
    % Mins and maxes for similarities
    
    simsigs=res{comparisoncount}.simsigs;
    simnons=res{comparisoncount}.simnons;

    mins=min(abs(simsigs{1}'));
    maxs=max(abs(simsigs{1}'));

    for n=2:length(simsigs)
        if ~isempty(simsigs{n})         
            mins=min([mins',abs(simsigs{n})]');
            maxs=max([maxs',abs(simsigs{n})]');
        end
    end
    
    res{comparisoncount}.simmins=mins;
    res{comparisoncount}.simmaxs=maxs;

    
    % Mins and maxes for naturalness
    
    
    natsigs=res{comparisoncount}.natsigs;
    natnons=res{comparisoncount}.natnons;

    mins=min(abs(natsigs{1}'));
    maxs=max(abs(natsigs{1}'));

    for n=2:length(natsigs)
        if ~isempty(natsigs{n})         
            mins=min([mins',abs(natsigs{n})]');
            maxs=max([maxs',abs(natsigs{n})]');
        end
    end
    
    res{comparisoncount}.natmins=mins;
    res{comparisoncount}.natmaxs=maxs;   
    
    
    res{comparisoncount}.natperformances=zeros(length(featlist),20);    
    res{comparisoncount}.simperformances=zeros(length(featlist),20);    
        
end



