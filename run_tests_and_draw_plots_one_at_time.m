
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


if 1 == 0
  evaluate_test_2008;
  evaluate_test_2009;
  evaluate_test_2010;
  evaluate_test_2011;
  evaluate_test_2012;
  evaluate_test_2013;
end


if 1 == 0
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

comparisontypeslist={ {'Unit selection systems only', 1} ...
                      {'HMM-systems only',2} ...
                      {'All systems', 1:3 } };

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


end

%
%
%  Grouped by significance:
%
%


hFig = figure(600);
set(hFig, 'Position', [0 0 1500 1000]);

featlist=[2,11,27,38];

binsteps=20;


plotcounter=0;

handbookplottables = cell(1,size(simsigs{1},1));
handbookcurves = cell(1,size(simsigs{1},1));


%%%% For all feats! 

for feat=1:size(simsigs{1},1);    

    clf
    
    for comparisoncount=1:3                    
        
        comparisonname=comparisontypeslist{comparisoncount}{1};
        
        simsigs=res{comparisoncount}.simsigs;
        simnons=res{comparisoncount}.simnons;
        
        logbase=10;
        
        if feat>20
            logbase=30;
        end
        
        mins=res{comparisoncount}.simmins;
        maxs=res{comparisoncount}.simmaxs;
        
        binstepsize=(maxs(feat)-mins(feat))/binsteps;
        binstepsize=roundn(binstepsize,floor(log10(binstepsize)));

        binmin=floor(mins(feat)/binstepsize)*binstepsize;
        binmax=ceil(maxs(feat)/binstepsize)*binstepsize;

        binedges=[binmin:binstepsize:binmax];


        logbins=(logbase.^(0:1/(length(binedges)-1):1)-1)/(logbase-1);

        logbinedges=(binmax-binmin)*logbins;

        labeledges=cell(size(binedges));
        labelskip=1;
        if binstepsize>80
           labelskip=2;
        end
        for n=1:labelskip:length(binedges)
            labeledges{n}=round(100*logbinedges(n))/100;
        end

%        sigsbinc=zeros(0,0);
%        negsbinc=zeros(0,0);
%        nonsbinc=zeros(0,0);

        histsigs=zeros(0,0);
        histnons=zeros(0,0);       

        for m=1:length(simsigs)
            if ~isempty(simsigs{m})
                histsigs=[histsigs,simsigs{m}];
            end
            if ~isempty(simnons{m})
                histnons=[histnons,simnons{m}];
            end
        end

        vals=histsigs(feat,:);
        nonvals=histnons(feat,:);

        normvals=vals/max(vals)*0.9;
        normnonvals=nonvals/max(vals)*0.9;

        sigsbinc=histc(normvals(normvals>0),logbins);
        negsbinc=histc(abs(normvals(normvals<0)),logbins);
        nonsbinc=histc(abs(normnonvals),logbins);     

        
        %
        % Here we smooth the results with an n-nearest neighbour average:
        %
        % where the number of neighbours to count is 
        
        nn=10;

        good2vals=(vals(normvals>0));
        bad2vals=abs(vals(normvals<0));
        non2vals=(abs(nonvals));

        goodtable=[good2vals', ones(size(good2vals'))];
        badtable=[bad2vals', -ones(size(bad2vals'))];
        nontable=[non2vals', -zeros(size(non2vals'))];

        alltable=[goodtable;badtable;nontable];
        alltable=sortrows(alltable,1);

        z=alltable(:,1);
        x=zeros(size(z));

        for i=1:length(z)
            x(i)=sum(alltable(max(1,i-nn):min(i+nn,length(z)),2)==1)/( min(i+nn,length(z))-max(1,i-nn) );

        end

        handbookcurves{feat}={z,x}; 
        
        handbookplottables{feat} = [sigsbinc;negsbinc;nonsbinc];

        
        srvals=sort(vals);
        srnonvals=sort(nonvals);
        
        accum=zeros(sum(srvals>0),1);
        nonsaccum=zeros(sum(srvals>0),1);
        
        ct=0;
        for m=min(find(srvals>0)):length(srvals)
            ct=ct+1;
            accum(ct)=sum((srvals>srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
            nonsaccum(ct)=sum((srvals>srvals(m)))/(  sum(srvals>srvals(m)) + sum(srvals<(-srvals(m))) + sum(srnonvals<(-srvals(m))) + sum(srnonvals>srvals(m))  );
        end

        invaccum=zeros(sum(srvals<0),1);  
        nonsinvaccum=zeros(sum(srvals<0),1);
        ct=0;
        for m=1:max(find(srvals<0))
            ct=ct+1;
            invaccum(ct)=sum((srvals<srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
            nonsinvaccum(ct)=sum((srvals<srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m))))+ sum((srnonvals<(-srvals(m)))) + sum((srnonvals>(srvals(m)))));
        end 

        performances=zeros(length(featlist),12);
        
        performances(feat,1)=0;
        performances(feat,2)=sum(vals>0)/(sum(vals<inf)+sum(nonvals<inf));   


        thr50=max(0,srvals(min(find(nonsaccum>0.5))));
        if (isempty(thr50))
            thr50=-1
        end
            performances(feat,3)=thr50;
            performances(feat,4)=sum(nonsaccum>0.5)/(sum(vals<inf)+sum(nonvals<inf));
                
        thr75=max(0,srvals(min(find(nonsaccum>0.75))));   
        
        if (isempty(thr75))
            thr75=-1;
        end
            performances(feat,5)=thr75;
            performances(feat,6)=sum(nonsaccum>0.75)/(sum(vals<inf)+sum(nonvals<inf));

        thr90=max(0,srvals(min(find(nonsaccum>0.9))));
        if (isempty(thr90))
            thr90=-1;
        end            

        performances(feat,7)=thr90;
        performances(feat,8)=sum(nonsaccum>0.9)/(sum(vals<inf)+sum(nonvals<inf));
                
        thr95=max(0,srvals(min(find(nonsaccum>0.95))));
        if (isempty(thr95))
            thr95 = -1;            
        end
        
        performances(feat,9)=thr95;
        performances(feat,10)=sum(nonsaccum>0.95)/(sum(vals<inf)+sum(nonvals<inf));

        
                
        res{comparisoncount}.simperformances=performances;
        
        subplot(3,2,2*comparisoncount-1);
        
         if (comparisoncount == 1)
                suptitle(['Proportion of correct evaluations for feat ',num2str(feat), ': ',testlist{feat}] )
        end


        Value_difference=handbookcurves{feat}{1};
        Smoothed_probability=handbookcurves{feat}{2};
        % Add miniscule noise to make values unique:
        %if feat>37
        Value_difference=Value_difference+10^-12*rand(size(Value_difference));
        %end
        
        disp(['Similarity, ',comparisonname, '  thresholds 50/75/90/95:']);
        disp([thr50,thr75,thr90,thr95]);

        myfit=fitit(Value_difference,Smoothed_probability)

        hold on 
        if thr50>=0
            line([thr50,thr50],[0,1],'color','b')
            text(thr50,0.05,'50%');
        end
        if thr75>=0
            line([thr75,thr75],[0,1],'color','g')
            text(thr75,0.1,'75%');
        end
        if thr90>=0
            line([thr90,thr90],[0,1],'color','r')
            text(thr90,0.15,'90%');
        end
        if thr95>=0
            line([thr95,thr95],[0,1],'color','m')
            text(thr95,0.2,'95%'); 
        end        
        
        
        % if feat==max(featlist)
        if comparisoncount == 1
            legend('Correct evaluations in NN-window','LOWESS smoothed probability',2,'Location','SouthEast')
        else
            legend off
        end
        xlabel('Value difference');
        ylabel('% correct significant evaluations');
        %axis([0,max(),0,1]);

        grid minor
        title(['Similarity, ',comparisonname],'FontSize',18); 


        
    end

    
    %%% NATURALNEESS!!!
    
  
    for comparisoncount=1:3                    
        
        comparisonname=comparisontypeslist{comparisoncount}{1};
        
        natsigs=res{comparisoncount}.natsigs;
        natnons=res{comparisoncount}.natnons;
        
        logbase=10;
        
        if feat>20
            logbase=30;
        end
        
        mins=res{comparisoncount}.natmins;
        maxs=res{comparisoncount}.natmaxs;
        
        binstepsize=(maxs(feat)-mins(feat))/binsteps;
        binstepsize=roundn(binstepsize,floor(log10(binstepsize)));

        binmin=floor(mins(feat)/binstepsize)*binstepsize;
        binmax=ceil(maxs(feat)/binstepsize)*binstepsize;

        binedges=[binmin:binstepsize:binmax];


        logbins=(logbase.^(0:1/(length(binedges)-1):1)-1)/(logbase-1);

        logbinedges=(binmax-binmin)*logbins;

        labeledges=cell(size(binedges));
        labelskip=1;
        if binstepsize>80
           labelskip=2;
        end
        for n=1:labelskip:length(binedges)
            labeledges{n}=round(100*logbinedges(n))/100;
        end

%        sigsbinc=zeros(0,0);
%        negsbinc=zeros(0,0);
%        nonsbinc=zeros(0,0);

        histsigs=zeros(0,0);
        histnons=zeros(0,0);       

        for m=1:length(natsigs)
            if ~isempty(natsigs{m})
                histsigs=[histsigs,natsigs{m}];
            end
            if ~isempty(natnons{m})
                histnons=[histnons,natnons{m}];
            end
        end

        vals=histsigs(feat,:);
        nonvals=histnons(feat,:);

        normvals=vals/max(vals)*0.9;
        normnonvals=nonvals/max(vals)*0.9;

        sigsbinc=histc(normvals(normvals>0),logbins);
        negsbinc=histc(abs(normvals(normvals<0)),logbins);
        nonsbinc=histc(abs(normnonvals),logbins);     

        
        %
        % Here we smooth the results with an n-nearest neighbour average:
        %
        % where the number of neighbours to count is 
        
        nn=10;

        good2vals=(vals(normvals>0));
        bad2vals=abs(vals(normvals<0));
        non2vals=(abs(nonvals));

        goodtable=[good2vals', ones(size(good2vals'))];
        badtable=[bad2vals', -ones(size(bad2vals'))];
        nontable=[non2vals', -zeros(size(non2vals'))];

        alltable=[goodtable;badtable;nontable];
        alltable=sortrows(alltable,1);

        z=alltable(:,1);
        x=zeros(size(z));

        for i=1:length(z)
            x(i)=sum(alltable(max(1,i-nn):min(i+nn,length(z)),2)==1)/( min(i+nn,length(z))-max(1,i-nn) );

        end

        handbookcurves{feat}={z,x}; 
        
        handbookplottables{feat} = [sigsbinc;negsbinc;nonsbinc];

          srvals=sort(vals);
        srnonvals=sort(nonvals);
        
        accum=zeros(sum(srvals>0),1);
        nonsaccum=zeros(sum(srvals>0),1);
        
        ct=0;
        for m=min(find(srvals>0)):length(srvals)
            ct=ct+1;
            accum(ct)=sum((srvals>srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
            nonsaccum(ct)=sum((srvals>srvals(m)))/(  sum(srvals>srvals(m)) + sum(srvals<(-srvals(m))) + sum(srnonvals<(-srvals(m))) + sum(srnonvals>srvals(m))  );
        end

        invaccum=zeros(sum(srvals<0),1);  
        nonsinvaccum=zeros(sum(srvals<0),1);
        ct=0;
        for m=1:max(find(srvals<0))
            ct=ct+1;
            invaccum(ct)=sum((srvals<srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
            nonsinvaccum(ct)=sum((srvals<srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m))))+ sum((srnonvals<(-srvals(m)))) + sum((srnonvals>(srvals(m)))));
        end 

        performances=zeros(length(featlist),12);
        
        performances(feat,1)=0;
        performances(feat,2)=sum(vals>0)/(sum(vals<inf)+sum(nonvals<inf));   


        thr50=max(0,srvals(min(find(nonsaccum>0.5))));
        if (isempty(thr50))
            thr50=-1
        end
            performances(feat,3)=thr50;
            performances(feat,4)=sum(nonsaccum>0.5)/(sum(vals<inf)+sum(nonvals<inf));
                
        thr75=max(0,srvals(min(find(nonsaccum>0.75))));   
        
        if (isempty(thr75))
            thr75=-1;
        end
            performances(feat,5)=thr75;
            performances(feat,6)=sum(nonsaccum>0.75)/(sum(vals<inf)+sum(nonvals<inf));

        thr90=max(0,srvals(min(find(nonsaccum>0.9))));
        if (isempty(thr90))
            thr90=-1;
        end            

        performances(feat,7)=thr90;
        performances(feat,8)=sum(nonsaccum>0.9)/(sum(vals<inf)+sum(nonvals<inf));
                
        thr95=max(0,srvals(min(find(nonsaccum>0.95))));
        if (isempty(thr95))
            thr95 = -1;            
        end
        
        performances(feat,9)=thr95;
        performances(feat,10)=sum(nonsaccum>0.95)/(sum(vals<inf)+sum(nonvals<inf));

        
                
        res{comparisoncount}.simperformances=performances;
        
        subplot(3,2,2*comparisoncount);
        
         if (comparisoncount == 1)
                suptitle(['Proportion of correct evaluations for feat ',num2str(feat), ': ',testlist{feat}] )
        end


        Value_difference=handbookcurves{feat}{1};
        Smoothed_probability=handbookcurves{feat}{2};
        % Add miniscule noise to make values unique:
        %if feat>37
        Value_difference=Value_difference+10^-12*rand(size(Value_difference));
        %end
        
        disp(['Similarity, ',comparisonname, '  thresholds 50/75/90/95:']);
        disp([thr50,thr75,thr90,thr95]);

        myfit=fitit(Value_difference,Smoothed_probability)

        hold on 
        if thr50>=0
            line([thr50,thr50],[0,1],'color','b')
            text(thr50,0.05,'50%');
        end
        if thr75>=0
            line([thr75,thr75],[0,1],'color','g')
            text(thr75,0.1,'75%');
        end
        if thr90>=0
            line([thr90,thr90],[0,1],'color','r')
            text(thr90,0.15,'90%');
        end
        if thr95>=0
            line([thr95,thr95],[0,1],'color','m')
            text(thr95,0.2,'95%'); 
        end        
        
        
        % if feat==max(featlist)
        if comparisoncount == 1
            legend('Correct evaluations in NN-window','LOWESS smoothed probability',2,'Location','SouthEast')
        else
            legend off
        end
        xlabel('Value difference');
        ylabel('% correct significant evaluations');
        %axis([0,max(),0,1]);

        grid minor
        title(['Naturalness, ',comparisonname],'FontSize',18); 


        
    end  
    
    waitforbuttonpress
    
end
