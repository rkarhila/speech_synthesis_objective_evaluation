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
%
%   Similarity and naturalness for all test data.
%
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

res = { struct('simnons',{{}},'simsigs',{{}},'simmins',[],'simmaxs',[],'simspeakers',{{}}, 'simperformances', {{}}, 'simbest',{{}}, 'natnons',{{}},'natsigs',{{}},'natmins',[],'natmaxs',[],'natspeakers',{{}}, 'natperformances', {{}}, 'natbest',{{}} ), ...
        struct('simnons',{{}},'simsigs',{{}},'simmins',[],'simmaxs',[],'simspeakers',{{}}, 'simperformances', {{}}, 'simbest',{{}}, 'natnons',{{}},'natsigs',{{}},'natmins',[],'natmaxs',[],'natspeakers',{{}}, 'natperformances', {{}}, 'natbest',{{}} ), ...
        struct('simnons',{{}},'simsigs',{{}},'simmins',[],'simmaxs',[],'simspeakers',{{}}, 'simperformances', {{}}, 'simbest',{{}}, 'natnons',{{}},'natsigs',{{}},'natmins',[],'natmaxs',[],'natspeakers',{{}}, 'natperformances', {{}}, 'natbest',{{}} ) };

                  
for comparisoncount=1:3                      

    comparisontypes=comparisontypeslist{comparisoncount}{2};
    comparisonname=comparisontypeslist{comparisoncount}{1};


    n=0;
    m=0;

    for p=1:length(tests)
        for r=1:length(tests{p})
            t=tests{p}{r};

            disp(['test ',num2str(2007+p),' ',comparisontypeslist{comparisoncount}{1}]);
            [sigs, nons, correlations_sys, bestguesscorrect] = get_significance_distances_by_systemtype(t.name,t.results, load(t.subjective_resultfile), load(t.opinionmatrix),t.systems, t.systemtypes);

            
            for comparisontype=comparisontypes

                if t.testtype == 'sim'
                    n=n+1;
                    res{comparisoncount}.simnons{n}=nons{comparisontype};
                    res{comparisoncount}.simsigs{n}=sigs{comparisontype};
                    res{comparisoncount}.simspeakers{n}=t.speaker;
                    
                    disp(['From sim results:'])
                    correlations_sys{comparisontype}
                    res{comparisoncount}.simperformances{n}=correlations_sys{comparisontype};
                    
                    res{comparisoncount}.simbest{n}=bestguesscorrect{comparisontype};
                    
                else
                    m=m+1;
                    res{comparisoncount}.natnons{m}=nons{comparisontype};
                    res{comparisoncount}.natsigs{m}=sigs{comparisontype};          
                    res{comparisoncount}.natspeakers{m}=t.speaker;
                    
                    res{comparisoncount}.natperformances{m}=correlations_sys{comparisontype};

                    res{comparisoncount}.natbest{m}=bestguesscorrect{comparisontype};
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
    
    
    %res{comparisoncount}.natperformances=zeros(length(testlist),20);    
    %res{comparisoncount}.simperformances=zeros(length(testlist),20);    
        
end


natcorr=zeros(comparisoncount,ind);
simcorr=zeros(comparisoncount,ind);

for comparisoncount=1:3
   natcorrs=zeros(ind,length(res{comparisoncount}.natperformances));
   for i=1:length(res{comparisoncount}.natperformances)              
       natcorrs(:,i)=res{comparisoncount}.natperformances{i};       
   end
   natcorrs(natcorrs==0)=nan;
   natcorr(comparisoncount,:)=nanmean(natcorrs,2);

   simcorrs=zeros(ind,length(res{comparisoncount}.simperformances));
   for i=1:length(res{comparisoncount}.simperformances)              
       simcorrs(:,i)=res{comparisoncount}.simperformances{i};       
   end
   simcorrs(simcorrs==0)=nan;
   simcorr(comparisoncount,:)=nanmean(simcorrs,2);

end
abs(natcorr)
abs(simcorr)


natbest=zeros(ind,comparisoncount);
simbest=zeros(ind,comparisoncount);


for comparisoncount=1:3
   natbests=zeros(ind,length(res{comparisoncount}.natbest));
   for i=1:length(res{comparisoncount}.natbest)              
       natbests(:,i)=res{comparisoncount}.natbest{i};       
   end
   natbest(:,comparisoncount)=mean(natbests,2);
   
   simbests=zeros(ind,length(res{comparisoncount}.simbest));
   for i=1:length(res{comparisoncount}.simbest)              
       simbests(:,i)=res{comparisoncount}.simbest{i};       
   end
   simbest(:,comparisoncount)=mean(simbests,2);
   
   
end


