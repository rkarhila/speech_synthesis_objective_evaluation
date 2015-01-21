

%
%
%  Grouped by significance:
%
%


hFig = figure(600);
set(hFig, 'Position', [0 0 1500 1000]);

featlist=[2,11,27,38];

binsteps=10;


plotcounter=0;

handbookplottables = cell(1,size(simsigs{1},1));
handbookcurves = cell(1,size(simsigs{1},1));


%%%% For all feats! 

%for feat=[2,12,38,50] 
for feat=1:length(testlist)

    clf
    
    simmins=res{1}.simmins;
    simmaxs=res{2}.simmaxs;    

    natmins=res{1}.natmins;
    natmaxs=res{2}.natmaxs;    

    for comparisoncount=2:3     
        simmins=min(mins,res{comparisoncount}.simmins);
        simmaxs=max(maxs,res{comparisoncount}.simmaxs);
        
        natmins=min(mins,res{comparisoncount}.natmins);
        natmaxs=max(maxs,res{comparisoncount}.natmaxs);    
    end
     
    xmaxval=[-inf, -inf];
    
    for comparisoncount=1:3                    

        for testtype=0:1
        
            comparisonname=comparisontypeslist{comparisoncount}{1};

            if testtype==0          
                sigs=res{comparisoncount}.simsigs;
                nons=res{comparisoncount}.simnons;
                testname='Similarity';
            else
                sigs=res{comparisoncount}.natsigs;
                nons=res{comparisoncount}.natnons;
                testname='Naturalness';
            end
            logbase=10;

            if feat>20
                logbase=30;
            end

            histsigs=zeros(0,0);
            histnons=zeros(0,0);       

            for m=1:length(sigs)
                if ~isempty(sigs{m})
                    histsigs=[histsigs,sigs{m}];
                end
                if ~isempty(nons{m})
                    histnons=[histnons,nons{m}];
                end
            end

            vals=histsigs(feat,:);
            nonvals=histnons(feat,:);


            %
            % Here we smooth the results with an n-nearest neighbour average:
            %
            % where the number of neighbours to count is 

            nn=10;

            good2vals=(vals(vals>0));
            bad2vals=abs(vals(vals<0));
            non2vals=(abs(nonvals));

            goodtable=[good2vals', ones(size(good2vals'))];
            badtable=[bad2vals', -ones(size(bad2vals'))];
            %nontable=[non2vals', -zeros(size(non2vals'))];

            %alltable=[goodtable;badtable;nontable];
            alltable=[goodtable;badtable];
            alltable=sortrows(alltable,1);

            z=alltable(:,1);
            x=zeros(size(z));

            for i=1:length(z)
                x(i)=sum(alltable(max(1,i-nn):min(i+nn,length(z)),2)==1)/( min(i+nn,length(z))-max(1,i-nn)+1 );

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
            performances(feat,2)=sum(vals>0)/(sum(vals<inf));   


            thr50=max(0,srvals(min(find(accum>0.5))));
            if (isempty(thr50))
                thr50=-1
            end
                performances(feat,3)=thr50;
                performances(feat,4)=sum(accum>0.5)/(sum(vals<inf));

            thr75=max(0,srvals(min(find(accum>0.75))));   

            if (isempty(thr75))
                thr75=-1;
            end
                performances(feat,5)=thr75;
                performances(feat,6)=sum(accum>0.75)/(sum(vals<inf));

            thr90=max(0,srvals(min(find(accum>0.9))));
            if (isempty(thr90))
                thr90=-1;
            end            

            performances(feat,7)=thr90;
            performances(feat,8)=sum(accum>0.9)/(sum(vals<inf));

            thr95=max(0,srvals(min(find(accum>0.95))));
            if (isempty(thr95))
                thr95 = -1;            
            end

            performances(feat,9)=thr95;
            performances(feat,10)=sum(accum>0.95)/(sum(vals<inf));



            %res{comparisoncount}.simperformances=performances;

            subplot(3,2,2*comparisoncount-1+testtype);
     
            

            Value_difference=handbookcurves{feat}{1};
            Smoothed_probability=handbookcurves{feat}{2};
            % Add miniscule noise to make values unique:
            %if feat>37
            Value_difference=Value_difference+10^-12*rand(size(Value_difference));
            %end

            disp([testname,', ',comparisonname, '  thresholds 50/75/90/95:']);
            disp([thr50,thr75,thr90,thr95]);

            %myfit=fitit(Value_difference,Smoothed_probability)

            plot(Value_difference,Smoothed_probability,'ro');
            
            
            hold on 
                        
            % Set up fittype and options.
            %ft = fittype( 'a*(1./(1+exp(-b*(x-c))))-d*(1./(1+exp(-e*(x-f))))', 'independent', 'x', 'dependent', 'y' );
            %opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            %opts.Display = 'Off';
            %opts.Lower = [0 0 -max(Value_difference) 0 0 -max(Value_difference)];
            %opts.MaxIter = 2000;
            %opts.Robust = 'Bisquare';
            %opts.StartPoint = [0.922145914880582 0.218085009465261 0.728012434223707*max(Value_difference) 0.42682131558088 0.553021099030541 0.131141186759214*max(Value_difference)];
            %opts.Upper = [1 10 1 1 10 0.5];
            %opts.Upper = [1 10 max(Value_difference) 1 10 0.5*max(Value_difference)];
            
            

            % Fit model to data.
            %[fitresult, gof] = fit( Value_difference, Smoothed_probability, ft, opts );
            %plot(fitresult,'b--');


            
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

            
            % A smoothing spline to give a rough estimate of the
            % probability of correct guesses:
            
            % Set up fittype and options.
            ft = fittype( 'smoothingspline' );
            opts = fitoptions( 'Method', 'SmoothingSpline' );
            opts.Normalize = 'on';
            opts.SmoothingParam = 0.95;

            % Fit model to data.
            [fitresult, gof] = fit( Value_difference, Smoothed_probability, ft, opts );

            h = plot(fitresult,'b');
            h(1).LineWidth =2;


            

            % if feat==max(featlist)
            if comparisoncount+testtype == 4
                legend('Correct evaluations in NN-window','Smoothed spline',2,'Location','East')
            else
                legend off
            end
            xlabel('Value difference','FontSize',12);
            ylabel('% correct significant evaluations','FontSize',12);

            grid minor
            title([testname,', ',comparisonname],'FontSize',15); 

            
            % Now for some funky histograms:

            
            
            %binstepsize=(maxs(feat)-mins(feat))/binsteps;
            %binstepsize=roundn(binstepsize,floor(log10(binstepsize)));

            %binmin=floor(mins(feat)/binstepsize)*binstepsize;
            %binmax=ceil(maxs(feat)/binstepsize)*binstepsize;

            %binedges=[binmin:binstepsize:binmax];


            %logbins=(logbase.^(0:1/(length(binedges)-1):1)-1)/(logbase-1);

            %logbinedges=(binmax-binmin)*logbins;

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


            allvals=sort([abs(vals),abs(nonvals)])';            
            binwidth=ceil(length(allvals)/binsteps);
            
            binedges=( allvals([binwidth:binwidth:length(allvals)-1]) + allvals([binwidth+1:binwidth:length(allvals)]) ) / 2;
            binedges=[0;binedges;(allvals(length(allvals)))];
            
            sigsbinc=histc(vals(vals>0),binedges);
            negsbinc=histc(abs(vals(vals<0)),binedges);
            nonsbinc=histc(abs(nonvals),binedges);     

            bincs=[sigsbinc;nonsbinc;negsbinc];
            %bincs=[sigsbinc;zeros(size(sigsbinc));negsbinc];
            bincs=(bincs./ repmat(sum(bincs,1),3,1))*0.2

            upedge=1.25
            ycoords=cumsum(bincs,1);
            
            for h=1:length(binedges)-1
                if bincs(1,h) > 0
                    rectangle('Position', [binedges(h), upedge-ycoords(1,h), binedges(h+1)-binedges(h), bincs(1,h)], 'FaceColor','g')
                end
                if bincs(2,h) > 0
                    rectangle('Position', [binedges(h), upedge-ycoords(2,h), binedges(h+1)-binedges(h), bincs(2,h)], 'FaceColor','y')
                end
                if bincs(3,h)
                    rectangle('Position', [binedges(h), upedge-ycoords(3,h), binedges(h+1)-binedges(h), bincs(3,h)], 'FaceColor','r')
                end
            end

            %xmaxval(testtype+1)=max(xmaxval(testtype+1),(binedges(end)+binedges(end-1))/2);
            xmaxval(testtype+1)=max(xmaxval(testtype+1),allvals(round(0.98*length(allvals))));
            
        end

    end

    for comparisoncount=1:3
        for testtype=0:1
            subplot(3,2,2*comparisoncount-1+testtype);
            %axis([0,maxs(feat),-0.2,1]);
            axis([0,xmaxval(testtype+1),0,1.25]);
        end
    end

    
    
    h = suptitle(['Proportion of correct evaluations for feat ',num2str(feat), ': ',testlist{feat}])
    set(h,'FontSize',18,'FontWeight','normal')
    
    
    %waitforbuttonpress
    export_fig('-painters','-r600','-q101',['results/figures/pair_evaluations_for_feature_',num2str(feat),'_fixed_logistics.pdf'])
end
