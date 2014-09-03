
local_conf

% Figurecounter
fc=100

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


if 1 == 1
  evaluate_test_2008
  evaluate_test_2009
  evaluate_test_2010
  evaluate_test_2011
  evaluate_test_2012
  evaluate_test_2013
end

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

for comparisoncount=1:3                      

    comparisontypes=comparisontypeslist{comparisoncount}{2};
    comparisonname=comparisontypeslist{comparisoncount}{1};


    simnons=cell(0);
    simsigs=cell(0);
    n=0;

    simspeakers=cell(0);


    natnons=cell(0);
    natsigs=cell(0);
    m=0;

    natspeakers=cell(0);



    for p=1:length(tests)
        for r=1:length(tests{p})
            t=tests{p}{r}

            [sigs,nons]=get_significance_distances_by_systemtype(t.results, load(t.subjective_resultfile), load(t.opinionmatrix),t.systems, t.systemtypes);

            for comparisontype=comparisontypes

                if t.testtype == 'nat'
                    n=n+1;
                    simnons{n}=nons{comparisontype};
                    simsigs{n}=sigs{comparisontype};
                    simspeakers{n}=t.speaker;
                else
                    m=m+1;
                    natnons{m}=nons{comparisontype};
                    natsigs{m}=sigs{comparisontype};          
                    natspeakers{m}=t.speaker;
                end
            end
        end
    end


    % Let's check similarities:

    [speakers,IA,IC] = unique(simspeakers, 'stable')

    mins=min([simnons{1},simsigs{1}]');
    maxs=max([simnons{1},simsigs{1}]');

    for n=2:length(simnons)
       if ~isempty(simnons{n}) &&  ~isempty(simsigs{n})
       mins=min([mins',simnons{n},simsigs{n}]');
       maxs=max([maxs',simnons{n},simsigs{n}]');
       end
    end

    %figure
    %featlist=[2,11,27];

    binsteps=20;

%     for featc=1:length(featlist);
% 
%         feat=featlist(featc);
% 
%         binstepsize=(maxs(feat)-mins(feat))/binsteps;
%         binstepsize=(maxs(feat))/binsteps;
% 
%         binstepsize=roundn(binstepsize,floor(log10(binstepsize)));
% 
% 
%         binmin=floor(mins(feat)/binstepsize)*binstepsize;
%         binmax=ceil(maxs(feat)/binstepsize)*binstepsize;
% 
%         binedges=[binmin:binstepsize:binmax];
% 
%         histsigs=zeros(0,0);
%         histnons=zeros(0,0);
%         n=1;
%         for m=find(IC==n)
%             histsigs=[histsigs;simsigs{m}];
%             histnons=[histnons;simnons{m}];
%         end
% 
%         sigsbinc=histc(histsigs(feat,:),binedges);
%         nonsbinc=histc(histnons(feat,:),binedges);
% 
%         for n=2:length(speakers)
% 
%             histsigs=zeros(0,0);
%             histnons=zeros(0,0);       
% 
%             for m=find(IC==n)
%                 histsigs=[histsigs;simsigs{m}];
%                 histnons=[histnons;simnons{m}];
%             end
% 
%             sigsbinc=[sigsbinc;histc(histsigs(feat,:),binedges)];
%             nonsbinc=[nonsbinc;histc(histnons(feat,:),binedges)];
%         end
% 
%         subplot(length(featlist),1,featc);
%         bar(binedges,sigsbinc','stacked')
%         hold on
%         bar(binedges,-nonsbinc','stacked')
%         title(['feature ',num2str(feat),': ',testlist{feat}]);
% 
%         set(gca,'XTick',binedges-binstepsize/2,'XTickLabel',sprintf('%0.1f|', binedges));
% 
% 
%         axis([min(binedges)-0.55*binstepsize, max(binedges)-0.45*binstepsize,-1.1*max(sum(nonsbinc)),1.1*max(sum(sigsbinc))]);
% 
% 
%     end



    mins=min(abs(simsigs{1}'));
    maxs=max(abs(simsigs{1}'));

    for n=2:length(simsigs)
        if ~isempty(simsigs{n})         
            mins=min([mins',abs(simsigs{n})]');
            maxs=max([maxs',abs(simsigs{n})]');
        end
    end

    %
    %
    %  Grouped by significance:
    %
    %


    hFig = figure(fc);
    fc=fc+1;
    set(hFig, 'Position', [0 0 1000 1000]);

    featlist=[2,11,27,38];

    binsteps=20;

    performances=zeros(length(featlist),20);
    plotcounter=0;

    handbookplottables = cell(1,size(simsigs{1},1));
    handbookcurves = cell(1,size(simsigs{1},1));
    for feat=1:size(simsigs{1},1);    

        logbase=10
        
        if feat>20
            logbase=30
        end
        
        binstepsize=(maxs(feat)-mins(feat))/binsteps;
        binstepsize=roundn(binstepsize,floor(log10(binstepsize)));

        binmin=floor(mins(feat)/binstepsize)*binstepsize;
        binmax=ceil(maxs(feat)/binstepsize)*binstepsize;

        binedges=[binmin:binstepsize:binmax];


        logbins=(logbase.^(0:1/(length(binedges)-1):1)-1)/(logbase-1);

        logbinedges=(binmax-binmin)*logbins

        labeledges=cell(size(binedges));
        labelskip=1;
        if binstepsize>80
           labelskip=2;
        end
        for n=1:labelskip:length(binedges)
            labeledges{n}=round(100*logbinedges(n))/100;
        end

        sigsbinc=zeros(0,0);
        negsbinc=zeros(0,0);
        nonsbinc=zeros(0,0);

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

        
        srvals=sort(normvals);
        srnonvals=sort(normnonvals);
        
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
                
        performances(feat,1)=0;
        performances(feat,2)=sum(vals>0)/(sum(vals<inf)+sum(nonvals<inf));   

        performances(feat,3)=max(0,vals(min(find(accum>0.5))));
        performances(feat,4)=sum(accum>0.5)/(sum(vals<inf)+sum(nonvals<inf));

        thr75=max(0,vals(min(find(accum>0.75))));   
        if (~isempty(thr75))

            performances(feat,5)=thr75;
            performances(feat,6)=sum(accum>0.75)/(sum(vals<inf)+sum(nonvals<inf));

            thr90=max(0,vals(min(find(accum>0.9))));
            if (~isempty(thr90))
                performances(feat,7)=thr90;
                performances(feat,8)=sum(accum>0.9)/(sum(vals<inf)+sum(nonvals<inf));

                thr95=max(0,vals(min(find(accum>0.95))));
                if (~isempty(thr95))
                    performances(feat,19)=thr95;
                    performances(feat,10)=sum(accum>0.95)/(sum(vals<inf)+sum(nonvals<inf));
                end
            end    
        end

        performances(feat,11)=0;
        performances(feat,12)=sum(vals>0)/(sum(vals<inf));   

        thr50=max(0,vals(min(find(nonsaccum>0.5))));
        if ~isempty(thr50)
            performances(feat,13)=thr50;
            performances(feat,14)=sum(nonsaccum>0.5)/(sum(vals<inf));

            thr75=max(0,vals(min(find(nonsaccum>0.75))));   
            if (~isempty(thr75))

                performances(feat,15)=thr75;
                performances(feat,16)=sum(nonsaccum>0.75)/(sum(vals<inf));

                thr90=max(0,vals(min(find(nonsaccum>0.9))));
                if (~isempty(thr90))
                    performances(feat,17)=thr90;
                    performances(feat,18)=sum(nonsaccum>0.9)/(sum(vals<inf));

                    thr95=max(0,vals(min(find(nonsaccum>0.95))));
                    if (~isempty(thr95))
                        performances(feat,19)=thr95;
                        performances(feat,20)=sum(nonsaccum>0.95)/(sum(vals<inf));
                    end
                end    
            end
        end

        % Plots:


        if sum((featlist==feat))==1

            plotcounter = plotcounter+1;
            subplot(length(featlist),1,plotcounter);
            set(gca,'FontSize',12)
            allbincs=[negsbinc;nonsbinc;sigsbinc];


            bar(binedges,allbincs'*100/max(sum(allbincs)),'stacked')
            hold on

            grid minor
            set(gca, 'GridLineStyle', '-');
            set(gca,'XGrid','off','YGrid','on')

            set(gca,'YTick',[0, 50 , 75, 90, 100]);

            for m=1:1:length(binedges)-1
              text(binedges(m),sum(sigsbinc(:,m)),num2str(round(100*sum(sigsbinc(:,m))/(sum(sigsbinc(:,m)) + sum(negsbinc(:,m))))),...
              'HorizontalAlignment','center',...
              'VerticalAlignment','bottom'); 
            end

            title(['Similarity with feature ',num2str(feat),': ',testlist{feat}, ' ',comparisonname],'FontSize',18);

            set(gca,'XTick',binedges-binstepsize/2,'XTickLabel', labeledges);

            %plot(binedges,100*((sum(sigsbinc)+sum(negsbinc))./(sum(sigsbinc)+sum(negsbinc)+sum(nonsbinc))))
                testvals=vals(vals>0)

        %     accum=zeros(length(binedges),1);
        %     for m=1:length(accum)
        %         accum(m)=sum(sum(sigsbinc(:,m:length(accum))))/sum(sum(allbincs(:,m:length(accum))));
        %     end
        %     plot(binedges,100*accum)
        %     
        %     vals=sort(vals)
        %     accum=zeros(length(vals),1);
        %     for m=1:length(vals)
        %         accum(m)=sum((vals>vals(m)))/(sum((vals>vals(m)))+sum((vals<(-vals(m))))+sum(nonvals>vals(m)));
        %     end
        %     plot(vals,100*accum,'r');



            logvals=(log((srvals(srvals>0)*logbase+1)))/log(logbase);
            logvals=logvals*(max(vals)+binstepsize/2);
            plot(logvals-binstepsize/2,100*accum,'ro-');

            badlogvals=(log(abs(srvals(srvals<0))*logbase+1))/log(logbase);
            badlogvals=badlogvals*(max(vals)+binstepsize/2);
            plot(badlogvals-binstepsize/2,100*invaccum,'ro');

            logvals=(log((srvals(srvals>0)*logbase+1)))/log(logbase);
            logvals=logvals*(max(vals)+binstepsize/2);
            plot(logvals-binstepsize/2,100*nonsaccum,'mo-');

            badlogvals=(log(-(srnonvals(srnonvals<0))*logbase+1))/log(logbase);
            badlogvals=badlogvals*(max(vals)+binstepsize/2);
            plot(badlogvals-binstepsize/2,30*ones(size(badlogvals)),'mo');
            
            badlogvals=(log((srnonvals(srnonvals>0))*logbase+1))/log(logbase);
            badlogvals=badlogvals*(max(vals)+binstepsize/2);
            plot(badlogvals-binstepsize/2,20*ones(size(badlogvals)),'yo');
            
            
            axis([min(binedges)-0.55*binstepsize, max(binedges)-0.45*binstepsize,0,110]); %1.2*max(sum([negsbinc;nonsbinc;sigsbinc]))]);

            if feat==max(featlist)
               legend({'Significant Wrong','Non-significant','Significant Right'});

                xlabel('Difference in objective measure system means in test');
%                 
%                 figure
%                 hold on
%                 plot(logvals-binstepsize/2,100*nonsaccum,'mo-');
%                 plot(logvals-binstepsize/2,100*accum,'ro-');

            end

            
        end

    end

    performances



    hFig = figure(fc);
    fc=fc+1;
    set(hFig, 'Position', [0 0 1000 1000]);    
    plotcounter=0

    for feat=1:size(simsigs{1},1);    
        if sum((featlist==feat))==1
            plotcounter = plotcounter+1;
            subplot(length(featlist),1,plotcounter);
            
            Value_difference=handbookcurves{feat}{1};
            Smoothed_probability=handbookcurves{feat}{2};
            if feat>37
                Value_difference=Value_difference+10^-12*rand(size(Value_difference));
            end
            myfit=fitit(Value_difference,Smoothed_probability)

            if feat==max(featlist)
                legend('Correct evaluations in NN-window','LOWESS smoothed probability',2,'Location','SouthEast')
            else
                legend off
            end
            xlabel('Value difference');
            ylabel('% correct significant evaluations');
            %axis([0,max(),0,1]);
            
            grid minor
            title(['Proportion of correct evaluations for feat ',num2str(feat),': ',testlist{feat}, ' ',comparisonname],'FontSize',18); 
        end
    end
    
    figure(201)
    set(hFig, 'Position', [0 0 1000 1000]);    

    
    subplot(length(comparisontypeslist),1,comparisoncount)
    bar(performances(:,[2,4,6,8,10]))
    if comparisoncount==1
        legend({'% of pairs correct','% of values over 50% confidence','% of values over 75% confidence','% of values over 90% confidence','% of values over 95% confidence' })
    end
    title(['Trustworthiness of evaluation types, ',comparisonname]);
    axis([0,size(simsigs{1},1),0,1]);
    grid minor
    
    if 1==2

    %
    %   Grouped by speaker:
    %
    %

    hFig = figure(fc);
    fc=fc+1;
    set(hFig, 'Position', [0 0 1000 1000]);

    featlist=[2,11,27,32];

    binsteps=20;

    for featc=1:length(featlist);

        feat=featlist(featc)

        binstepsize=(maxs(feat)-mins(feat))/binsteps;
        binstepsize=roundn(binstepsize,floor(log10(binstepsize)));

        binmin=floor(mins(feat)/binstepsize)*binstepsize;
        binmax=ceil(maxs(feat)/binstepsize)*binstepsize;

        binedges=[binmin:binstepsize:binmax];
        %binedges=(logspace(0,log10(21),20)-1)/binmax;

        labeledges=cell(size(binedges));
        labelskip=1;
        if binstepsize>80
           labelskip=2;
        end
        for n=1:labelskip:length(binedges)
            labeledges{n}=binedges(n);
        end

        sigsbinc=zeros(0,0);
        negsbinc=zeros(0,0);
        nonsbinc=zeros(0,0);

        for n=1:length(speakers)

            histsigs=zeros(0,0);
            histnons=zeros(0,0);       

            for m=find(IC==n)
                histsigs=[histsigs;simsigs{m}];
                histnons=[histnons;simnons{m}];
            end

            vals=histsigs(feat,:);
            sigsbinc=[sigsbinc;histc(vals(vals>0),binedges)];
            negsbinc=[negsbinc;histc(abs(vals(vals<0)),binedges)];
            nonsbinc=[nonsbinc;histc(abs(histnons(feat,:)),binedges)];       

        end


        subplot(length(featlist),1,featc);
        set(gca,'FontSize',12)

        bar(binedges,sigsbinc','stacked')
        hold on
        bar(binedges,-negsbinc','stacked')    

        for m=1:1:length(binedges)-1
          text(binedges(m),sum(sigsbinc(:,m)),num2str(round(100*sum(sigsbinc(:,m))/(sum(sigsbinc(:,m)) + sum(negsbinc(:,m))))),...
          'HorizontalAlignment','center',...
          'VerticalAlignment','bottom'); 
        end

        title(['Similarity with feature ',num2str(feat),': ',testlist{feat}],'FontSize',18);

        set(gca,'XTick',binedges-binstepsize/2,'XTickLabel', labeledges);

        plot(binedges,100*((sum(sigsbinc)+sum(negsbinc))./(sum(sigsbinc)+sum(negsbinc)+sum(nonsbinc))))

        grid on

        axis([min(binedges)-0.55*binstepsize, max(binedges)-0.45*binstepsize,-1.1*max(sum(negsbinc)),110]);% 1.2*max(sum(sigsbinc))]);

        if featc==length(featlist)
           legend(simspeakers(IA));
           xlabel('Difference in objective measure system means in test');
        end


    end






    natnons=cell(8,1);
    natsigs=cell(8,1);
    n=0;




    mins=min(abs(natsigs{1})');
    maxs=max(abs(natsigs{1})');

    for n=2:8
       mins=min([mins',abs(natsigs{1})]');
       maxs=max([maxs',abs(natsigs{1})]') ;
    end



    hFig = figure(fc);
    fc=fc+1;
    set(hFig, 'Position', [0 0 1000 1000])

    featlist=[2,6,27,32];


    binsteps=20;

    for featc=1:length(featlist);

        feat=featlist(featc)

        binstepsize=(maxs(feat)-mins(feat))/binsteps

        binstepsize=roundn(binstepsize,floor(log10(binstepsize)))

        binmin=floor(mins(feat)/binstepsize)*binstepsize
        binmax=ceil(maxs(feat)/binstepsize)*binstepsize

        binedges=[binmin:binstepsize:binmax]

        labeledges=cell(size(binedges));
        labelskip=1;
        if binstepsize>80
           labelskip=2;
        end
        for n=1:labelskip:length(binedges)
            labeledges{n}=binedges(n)
        end

        vals=natsigs{1}(feat,:);        

        sigsbinc=histc(vals(vals>0),binedges);
        negsbinc=histc(abs(vals(vals<0)),binedges);   
        nonsbinc=histc(abs(natnons{1}(feat,:)),binedges);


        for n=2:8
            vals=natsigs{n}(feat,:);
            sigsbinc=[sigsbinc;histc(vals(vals>0),binedges)];
            negsbinc=[negsbinc;histc(abs(vals(vals<0)),binedges)];
            nonsbinc=[nonsbinc;histc(abs(natnons{1}(feat,:)),binedges)];       
        end

        subplot(length(featlist),1,featc);
         set(gca,'FontSize',12)
        bar(binedges,sigsbinc','stacked')
        hold on
        bar(binedges,-negsbinc','stacked')

        for m=1:1:length(binedges)-1
          text(binedges(m),sum(sigsbinc(:,m)),num2str(round(100*sum(sigsbinc(:,m))/(sum(sigsbinc(:,m)) + sum(negsbinc(:,m))))),...
          'HorizontalAlignment','center',...
          'VerticalAlignment','bottom'); 
        end

        title(['Naturalness with feature ',num2str(feat),': ',testlist{feat}],'FontSize',18);

        set(gca,'XTick',binedges-binstepsize/2,'XTickLabel', labeledges);

        plot(binedges,100*((sum(sigsbinc)+sum(negsbinc))./(sum(sigsbinc)+sum(negsbinc)+sum(nonsbinc))))

        grid on


        axis([min(binedges)-0.55*binstepsize, max(binedges)-0.45*binstepsize,-1.1*max(sum(negsbinc)),1.2*max(sum(sigsbinc))]);

        if featc==length(featlist)
           legend({'Roger','speakit','WJ','rjs','CAS','Nancy','Librivox','VF'},'location','best') 
           xlabel('Difference in objective measure system means in test');
        end

    end

    end

end
