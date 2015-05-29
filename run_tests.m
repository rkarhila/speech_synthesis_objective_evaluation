local_conf;

% Figurecounter
fc=100;


% First, let's make sure that we have all the tests run and results loaded:

if ~exist('tests','var')
    tests=cell(6,1);

    evaluate_test_2008;
    tests{1}=tests2008;

    evaluate_test_2009;
    tests{2}=tests2009;

    evaluate_test_2010;
    tests{3}=tests2010;

    evaluate_test_2011;
    tests{4}=tests2011;

    evaluate_test_2012;
    tests{5}=tests2012;

    evaluate_test_2013;
    tests{6}=tests2013;
end


%
% Then start extracting interesting bits from the results:
%


%
%   Similarity and naturalness for all test data.
%

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

% A complicated cell/structure-thing to store scores and statistics for the
% different comparisons:
            
comptypes={'all','unitsel','hmm'}

res = struct(...
    'all', struct('simnons',{{}},...
               'simsigs',{{}},...
               'simmins',[],...
               'simmaxs',[],...
               'simspeakers',{{}},...
               'simperformances', {{}}, ...
               'simbest',{{}}, ...
               'natnons',{{}},...
               'natsigs',{{}},...
               'natmins',[],...
               'natmaxs',[],...
               'natspeakers',{{}},...
               'natperformances', {{}},...
               'natbest',{{}} ), ...
     'unitsel', struct('simnons',{{}},...
               'simsigs',{{}},...
               'simmins',[],...
               'simmaxs',[],...
               'simspeakers',{{}},...
               'simperformances', {{}}, ...
               'simbest',{{}}, ...
               'natnons',{{}},...
               'natsigs',{{}},...
               'natmins',[],...
               'natmaxs',[],...
               'natspeakers',{{}},...
               'natperformances', {{}},...
               'natbest',{{}} ), ...               
      'hmm', struct('simnons',{{}},...
               'simsigs',{{}},...
               'simmins',[],...
               'simmaxs',[],...
               'simspeakers',{{}},...
               'simperformances', {{}}, ...
               'simbest',{{}}, ...
               'natnons',{{}},...
               'natsigs',{{}},...
               'natmins',[],...
               'natmaxs',[],...
               'natspeakers',{{}},...
               'natperformances', {{}},...
               'natbest',{{}} ) );

                  

for p=1:length(tests) % The year
    for r=1:length(tests{p}) % The task
        t=tests{p}{r}; 

        disp(['test ',num2str(2007+p),' ',comparisontypeslist{comparisoncount}{1}]);
        [sigs, nons, correlations_sys, bestguesscorrect] = get_significance_distances_by_systemtype(t.name,t.results, load(t.subjective_resultfile), load(t.opinionmatrix),t.systems, t.systemtypes);

        for comparisoncount=1:3                      
            comptype=char(comptypes(comparisoncount));

            %comparisontypes=comparisontypeslist{comparisoncount}{2};
            %comparisonname=comparisontypeslist{comparisoncount}{1};

            n=0;
            m=0;

            comparisontype=comparisoncount;    

            if strcmp(t.testtype,'sim')
                n=n+1;

                res.(comptype).simnons{n}=nons{comparisontype};
                res.(comptype).simsigs{n}=sigs{comparisontype};
                res.(comptype).simspeakers{n}=t.speaker;

                %disp(['From sim results:'])
                %correlations_sys{comparisontype};
                res.(comptype).simperformances{n}=correlations_sys{comparisontype};

                res.(comptype).simbest{n}=bestguesscorrect{comparisontype};

            else
                m=m+1;
                res.(comptype).natnons{m}=nons{comparisontype};
                res.(comptype).natsigs{m}=sigs{comparisontype};          
                res.(comptype).natspeakers{m}=t.speaker;

                res.(comptype).natperformances{m}=correlations_sys{comparisontype};

                res.(comptype).natbest{m}=bestguesscorrect{comparisontype};
            end
        end
    end
    
    
end



for comparisoncount=1:3               
     comptype=char(comptypes(comparisoncount));
   
    % Mins and maxes for similarities
    
    simsigs=res.(comptype).simsigs;
    simnons=res.(comptype).simnons;

    mins=min(abs(simsigs{1}'));
    maxs=max(abs(simsigs{1}'));

    for n=2:length(simsigs)
        if ~isempty(simsigs{n})         
            mins=min([mins',abs(simsigs{n})]');
            maxs=max([maxs',abs(simsigs{n})]');
        end
    end
    
    res.(comptype).simmins=mins;
    res.(comptype).simmaxs=maxs;

    
    % Mins and maxes for naturalness
    
    
    natsigs=res.(comptype).natsigs;
    natnons=res.(comptype).natnons;

    mins=min(abs(natsigs{1}'));
    maxs=max(abs(natsigs{1}'));

    for n=2:length(natsigs)
        if ~isempty(natsigs{n})         
            mins=min([mins',abs(natsigs{n})]');
            maxs=max([maxs',abs(natsigs{n})]');
        end
    end
    
    res.(comptype).natmins=mins;
    res.(comptype).natmaxs=maxs;   
    
    
    %res.(comptype).natperformances=zeros(length(testlist),20);    
    %res.(comptype).simperformances=zeros(length(testlist),20);    
        
end

ind=length(testlist);

natcorr=zeros(comparisoncount,length(testlist));
simcorr=zeros(comparisoncount,length(testlist));

for comparisoncount=1:3
   comptype=char(comptypes(comparisoncount));

    
   natcorrs=zeros(ind,length(res.(comptype).natperformances));
   for i=1:length(res.(comptype).natperformances)              
       natcorrs(:,i)=res.(comptype).natperformances{i};       
   end
   natcorrs(natcorrs==0)=nan;
   natcorr(comparisoncount,:)=nanmean(natcorrs,2);

   simcorrs=zeros(ind,length(res.(comptype).simperformances));
   for i=1:length(res.(comptype).simperformances)              
       simcorrs(:,i)=res.(comptype).simperformances{i};       
   end
   simcorrs(simcorrs==0)=nan;
   simcorr(comparisoncount,:)=nanmean(simcorrs,2);

end
abs(natcorr);
abs(simcorr);


natbest=zeros(ind,comparisoncount);
simbest=zeros(ind,comparisoncount);


for comparisoncount=1:3
   comptype=char(comptypes(comparisoncount));
    
   natbests=zeros(ind,length(res.(comptype).natbest));
   for i=1:length(res.(comptype).natbest)              
       natbests(:,i)=res.(comptype).natbest{i};       
   end
   natbest(:,comparisoncount)=mean(natbests,2);
   
   simbests=zeros(ind,length(res.(comptype).simbest));
   for i=1:length(res.(comptype).simbest)              
       simbests(:,i)=res.(comptype).simbest{i};       
   end
   simbest(:,comparisoncount)=mean(simbests,2);
   
   
end


