

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

for feat=[2,12,38,50] %1:size(simsigs{1},1);    

    clf

    
    
    mins=res{1}.simmins;
    maxs=res{2}.simmaxs;    

    for comparisoncount=2:3     
        mins=min(mins,res{comparisoncount}.simmins);
        maxs=max(maxs,res{comparisoncount}.simmaxs);
    end
    
    for comparisoncount=1:3                    
        
        comparisonname=comparisontypeslist{comparisoncount}{1};
        
        simsigs=res{comparisoncount}.simsigs;
        simnons=res{comparisoncount}.simnons;
        
        logbase=10;
        
        if feat>20
            logbase=30;
        end
        
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
        
        %accum=zeros(sum(srvals>0),1);
        accum=zeros(size(srvals));
        nonsaccum=zeros(sum(srvals>0),1);
        
        %ct=0;
        for m=min(find(srvals>0)):length(srvals)
            %ct=ct+1;
            accum(m)=sum((srvals>srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
            nonsaccum(m)=sum((srvals>srvals(m)))/(  sum(srvals>srvals(m)) + sum(srvals<(-srvals(m))) + sum(srnonvals<(-srvals(m))) + sum(srnonvals>srvals(m))  );
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
        axis([0,maxs(feat),0,1]);

        grid minor
        title(['Similarity, ',comparisonname],'FontSize',18); 


        
    end

    
    %%% NATURALNEESS!!!
    
    mins=res{1}.natmins;
    maxs=res{2}.natmaxs;    

    for comparisoncount=2:3     
        mins=min(mins,res{comparisoncount}.natmins);
        maxs=max(maxs,res{comparisoncount}.natmaxs);
    end
        
  
    for comparisoncount=1:3                    
        
        comparisonname=comparisontypeslist{comparisoncount}{1};
        
        natsigs=res{comparisoncount}.natsigs;
        natnons=res{comparisoncount}.natnons;
        
        logbase=10;
        
        if feat>20
            logbase=30;
        end
        
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
        
        % accum=zeros(sum(srvals>0),1);
        accum=zeros(size(srvals));
        nonsaccum=zeros(sum(srvals>0),1);
        
        %ct=0;
        for m=min(find(srvals>0)):length(srvals)
            %ct=ct+1;
            accum(m)=sum((srvals>srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
            nonsaccum(m)=sum((srvals>srvals(m)))/(  sum(srvals>srvals(m)) + sum(srvals<(-srvals(m))) + sum(srnonvals<(-srvals(m))) + sum(srnonvals>srvals(m))  );
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
        axis([0,maxs(feat),0,1]);

        grid minor
        title(['Naturalness, ',comparisonname],'FontSize',18); 


        
    end  
    
    waitforbuttonpress
    
end
