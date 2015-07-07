

% Gather results based on 
% 1) Corpora ie. training speaker
%    corporalist={'cas','librivox','nancy','rjs','roger','speakit',...
%                 'voice_forge','wj'};
% 2) Language
%    languagelist={'english','mandarin'};
% 3) Test type 
%    testtypelist={'nat','sim'};


%
% Tweak the lists below to leave out some tests:
%

corporalist={'cas','nancy','rjs','roger','speakit','voice_forge','wj'};
languagelist={'english','mandarin'};
systemtypeslist={'unit_selection','hmm'} % This is not yet implemented!
%testtypelist={'sim', 'nat'};
testtypelist={'sim'};


%%%% For all feats? No, just for the selected ones:

plottable_feats=1:length(conf.methodlist);

%

binsteps=10;
plottable_bins=10;


interesting_thresholds=[75,90,95];

res=struct(...
    'all', struct(...
           'non_significant_values',{{}},...
           'significant_values',{{}},...
           'mins',[],...
           'maxs',[],...
           'speakers',{{}},...
           'correlation_data', {{}}, ...
           'best_shots',{{}},...
           'test_names',{{}},...
           'test_size',[]),...
    'only_unitsel', struct(...
           'non_significant_values',{{}},...
           'significant_values',{{}},...
           'mins',[],...
           'maxs',[],...
           'speakers',{{}},...
           'correlation_data', {{}}, ...
           'best_shots',{{}},...
           'test_names',{{}},...
           'test_size',[]), ...      
    'only_hmm', struct(...
           'non_significant_values',{{}},...
           'significant_values',{{}},...
           'mins',[],...
           'maxs',[],...
           'speakers',{{}},...
           'correlation_data', {{}}, ...
           'best_shots',{{}},...
           'test_names',{{}},...
           'test_size',[]));

       

comparisontypeslist={ {'All systems', 1:3 }, ...
                      {'Unit selection systems only', 1}, ...
                      {'HMM-systems only',2}  };     
comptypes={'all','only_unitsel','only_hmm'};
n=0;       


languages_in_test={};
corpora_in_test={};
test_types_in_test={};



for p=1:length(tests) % The year
    for r=1:length(tests{p}) % The task
        t=tests{p}{r}; 

        % Check if we include this test in our analysis:
        
        if (ismember(t.language, languagelist)) && ...
                (ismember(t.speaker,corporalist)) && ...
                (ismember(t.testtype, testtypelist))

            % Book-keeping for the name of the plot:
            if ~ismember(t.language, languages_in_test)
                languages_in_test{length(languages_in_test)+1} = t.language;
            end
            if ~ismember(t.speaker, corpora_in_test)
                corpora_in_test{length(corpora_in_test)+1} = t.speaker;
            end           
             if ~ismember(t.testtype, test_types_in_test)
                test_types_in_test{length(test_types_in_test)+1} = t.testtype;
            end            
            
            % Get the interesting numbers:
            [sigs, nons, correlation_data, bestguesscorrect, siglabels1, nonlabels1, test_size] = ...
                get_significance_distances_with_labels(...
                t.name,...
                t.results,...
                load(t.subjective_resultfile),...
                load(t.opinionmatrix),...
                t.systems,...
                t.systemtypes,...
                textread(t.testfilelist,'%s' ));
            
            n=n+1;
            for comparisoncount=1:3
                disp(['test ',num2str(2007+p),' ',comparisontypeslist{comparisoncount}{1}]);
                
                comptype=char(comptypes(comparisoncount));
                
                
                
                res.(comptype).non_significant_values{n}=zeros(0,0);
                res.(comptype).significant_values{n}=zeros(0,0);

                res.(comptype).significant_values_labels{n}={};
                res.(comptype).non_significant_values_labels{n}={};
               
                
                % TODO: Add the labels
                
                for y=comparisontypeslist{comparisoncount}{2}

                    %
                    % Collect the values:
                    
                    res.(comptype).non_significant_values{n}= [res.(comptype).non_significant_values{n},nons{y}];
                    res.(comptype).significant_values{n}=[res.(comptype).significant_values{n}, sigs{y}];
                    
                    %
                    % Get the labels also:
                    
                    res.(comptype).significant_values_labels{n}=[res.(comptype).significant_values_labels{n}; siglabels1{y}];
                    res.(comptype).non_significant_values_labels{n}=[res.(comptype).significant_values_labels{n}; nonlabels1{y}];
                    
                end
                
                res.(comptype).correlation_data{n}=correlation_data{comparisoncount};
                res.(comptype).best_shot{n}=bestguesscorrect{comparisoncount};                    

                res.(comptype).test_names{n}=t.name;
                res.(comptype).test_size(n)=test_size{comparisoncount};
            
            end
        end
    end 
end





%
%
%  Grouped by significance:
%
%


hFig = figure(600);

set(hFig, 'Position', [0 0 1500 1000]);




%method_statistics=struct('thresholds',[], 'data_over_thresh',[],...
%                  'harsh_thresholds',[], 'harsh_data_over_thresh',[]);

%method_statistics=struct('all',struct('thresholds',[], 'data_over_thresh',[],...
%                  'harsh_thresholds',[], 'harsh_data_over_thresh',[], 'correlations',[]),...
%                  'only_unitsel', struct('thresholds',[], 'data_over_thresh',[],...
%                  'harsh_thresholds',[], 'harsh_data_over_thresh',[], 'correlations',[]),...
%                  'only_hmm',  struct('thresholds',[], 'data_over_thresh',[],...
%                  'harsh_thresholds',[], 'harsh_data_over_thresh',[], 'correlations',[]) );


              
reports=cell(length(comparisontypeslist),2);

for r=1:length(comparisontypeslist)
   reports{r}= {...
       char(strcat({'  Results for '},test_types_in_test , {' comparing '}, char(comparisontypeslist{r}{1}) )),...
       '  ignoring the cases where listeners could not reach a decision.',...
       '',...
       char(strcat({'    Speakers:  '}, strjoin(corpora_in_test, ', '))),...
       char(strcat({'   Languages:  '}, strjoin(languages_in_test, ', '))),...
       '',...
       ' --- Not including insignificant subj. diff. -- |     ---- including subj. diff. ------         |',...
       '    Threshold values    | % of data over thresh.|    Threshold values   |% of data over thresh  |     Median',...',...
       ' 75%     90%     95%    | 75%     90%     95%   |  75%   90%     95%    |  75%   90%     95%    |  correlation  | Method'};
       %0.00    0.46    5.85    | 0.80  0.47    0.00    | 0.34  5.85    5.85    | 0.54  0.00    0.00    |       -0.76   | 18 Distortion: dtw with straight mcd , path cost with straight fws 
end
              
outliers_for_analysis=cell(length(conf.methodlist),3);              

for feat=plottable_feats

    clf
    
    comptype=comptypes{1};
    
    mins=res.(comptype).mins;
    maxs=res.(comptype).maxs;    


    for comparisoncount=2:3  
        comptype=comptypes{comparisoncount}
        mins=min(res.(comptype).mins, mins);
        maxs=max(res.(comptype).maxs, maxs);    
       
    end
     
    xmaxval=-inf;
    HA=cell(3,1);
    
    plot_positions=cell(3,1);
    labs_for_plot_positions=cell(3,1);
    
    for comparisoncount=1:3                    
        comptype=comptypes{comparisoncount};

%        for testtype=0:1
        
            comparisonname=comparisontypeslist{comparisoncount}{1};

            testname=[strjoin(corpora_in_test,', '),'; ',strjoin(languages_in_test,', '),'; ',strjoin(test_types_in_test,', '),': '];

            sigs=res.(comptype).significant_values;            
            siglabels=res.(comptype).significant_values_labels;
            
            nons=res.(comptype).non_significant_values;
            nonlabels=res.(comptype).non_significant_values_labels;


            corr_data_src=res.(comptype).correlation_data;
            corr_data=zeros(0,0);
            
            histsigs=zeros(0,0);
            histnons=zeros(0,0);       

            histsiglabs={};
            histnonlabs={};
            
            for m=1:length(sigs)
                if ~isempty(sigs{m})
                    histsigs=[histsigs,sigs{m}];
                    histsiglabs=[histsiglabs;siglabels{m}];
                end
                if ~isempty(nons{m})
                    histnons=[histnons,nons{m}];
                    histnonlabs=[histnonlabs;nonlabels{m}];

                end
                if ~isempty(corr_data_src{m})
                    corr_data=[corr_data; corr_data_src{m}];
                end
            end


            % This is inefficient: We should loop the feats here, but it
            % goes a little against the idea of plotting each test feature
            % on its own page one at a time...

            vals=histsigs(feat,:);
            nonvals=histnons(feat,:);

            labs=histsiglabs;
            nonlabs=histnonlabs;

            %
            % Here we smooth the results with an n-nearest neighbour average:
            %
            % where the number of neighbours to count is 

            nn=10;

            good2vals=(vals(vals>0));
            good2labs=labs(find(vals>0));
            
            
            bad2vals=abs(vals(vals<0));
            bad2labs=labs(find(vals<0));

            
            non2vals=(abs(nonvals));
            non2labs=nonlabs; % TODO: why so?
            
            %
            %
            %  Smoothing the 0/1-values by n-nearest neighbour, via some
            %  complicated procedure that I have forgotten about:
            %
            goodtable=[good2vals', ones(size(good2vals'))];
            badtable=[bad2vals', -ones(size(bad2vals'))];

            alltable=[goodtable;badtable];
            [alltable, indexing]=sortrows(alltable,1);

            alllabs = [good2labs; bad2labs];
            alllabs=alllabs(indexing);
            
            z=alltable(:,1);

            % Remove soon:
%            x=zeros(size(z));
%            for i=1:length(z)
%                x(i)=sum(alltable(max(1,i-nn):min(i+nn,length(z)),2)==1)/( min(i+nn,length(z))-max(1,i-nn)+1 );
%            end

            
           
            %
            % Interpolate the non-significant test values into the smoothed
            % line:
            %
            % (Add tiny noise to make sure that the values are unique)
            %
            %
            %interpnonx=interp1(z+rand(size(z))*1e-10,x,min(max(non2vals, min(z)),max(z)),'pchip');
              
 
            
            alltable=[alltable; [ non2vals', zeros(size(non2vals'))]];
            alllabs=[alllabs; non2labs];
            
            [alltable, indexing]=sortrows(alltable,1);
            alllabs=alllabs(indexing);
 
            z=alltable(:,1);
            
            % Wait, how about not smoothing?
            x=(alltable(:,2));
            x(x==0)=0.375+0.25*rand(size(x(x==0)));
            x(x==-1)=0.0+0.25*rand(size(x(x==-1)));
            x(x==1)=0.75+0.25*rand(size(x(x==1)));
            
            
            plot_positions{comparisoncount}={z,x};
            labs_for_plot_positions{comparisoncount}=alllabs;
            goodorbad=alltable(:,2);
            
            srvals=sort(vals);            
            srnonvals=sort(nonvals);

            accum=zeros(size(srvals));
            nonsaccum=zeros(sum(srvals>0),1);

            %ct=0;
            for m=min(find(srvals>0)):length(srvals)
                %ct=ct+1;X
                accum(m) = sum((srvals>srvals(m))) / (  sum((srvals>srvals(m))) + sum((srvals<(-srvals(m))))  );
                nonsaccum(m)=sum((srvals>srvals(m)))/(  sum(srvals>srvals(m)) + sum(srvals<(-srvals(m))) + sum(srnonvals<(-srvals(m))) + sum(srnonvals>srvals(m))  );
            end

            % Remove the next line someday:
            %theoretical_best_possible=length(vals)/(length(vals)+length(nonvals));

            
%            
%     Inverse accumulation of scores, for what reason???
%
%             invaccum=zeros(sum(srvals<0),1);  
%             nonsinvaccum=zeros(sum(srvals<0),1);
%             ct=0;
%             for m=1:max(find(srvals<0))
%                 ct=ct+1;
%                 invaccum(ct)=sum((srvals<srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
%                 nonsinvaccum(ct)=sum((srvals<srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m))))+ sum((srnonvals<(-srvals(m)))) + sum((srnonvals>(srvals(m)))));
%             end 


            % Some threshold values. These could be the most interesting
            % result of these tests: Given that we want to be, say, 95%
            % sure that the objective measure agrees with the human
            % listeners, how much difference must there be in values for
            % a given objective measure?
            
            %
            % Also, how much of the data is above this "confidence"
            % threshold? This gives us a "goodness" value for the
            % particular method.
            %
            
            %
            % Sometimes the human listeners have not been able to decide on
            % which system is better. These cases are handles in two ways:
            %   1) The easy way: undecided tests are ignored.
            %   2) The harsh way: undecided tests are counted as failures.
             
             thrvals=zeros(size(interesting_thresholds));
             goodnessvals=zeros(size(interesting_thresholds));
             
             harshthrvals=zeros(size(interesting_thresholds));
             harshgoodnessvals=zeros(size(interesting_thresholds));

             pointer=0;
             
             for th=interesting_thresholds
                 pointer=pointer+1;
                 
                  thrval=max(0,srvals(min(find(accum> (th/100) ))));
                  if (isempty(thrval))
                     thrval=inf;
                  end            
                  thrvals(pointer)=thrval;
                  
                  goodnessval=1-(min(find(accum> (th/100) ))/length(accum));
                  if (isempty(goodnessval))
                     goodnessval=0;
                  end                
                   goodnessvals(pointer)=goodnessval;

                  harshthrval=max(0,srvals(min(find(nonsaccum> (th/100) ))));
                  if (isempty(harshthrval))
                    harshthrval=inf;
                  end
                  harshthrvals(pointer)=harshthrval;
                  
                  harshgoodnessval=(1-(min(find(nonsaccum> (th/100)))/length(nonsaccum)));
                  if (isempty(harshgoodnessval))
                    harshgoodnessval=0;
                  end              
                  harshgoodnessvals(pointer)=harshgoodnessval;

                  
             end
             
            % For fancy and nice reporting:
                 
            corr_vals=corr_data(:,feat);
            corr_val=median(corr_vals);
            
%             rep1={sprintf(['%0.2f\t%0.2f\t%0.2f\t%0.2f\t|\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t|\t%0.2f\t| ',...
%                 conf.methodlist{feat}.name],[thrvals(1:4) goodnessvals, corr_val])};
%             
%             rep2={sprintf(['%0.2f\t%0.2f\t%0.2f\t%0.2f\t|\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t|\t%0.2f\t| ',...
%                 conf.methodlist{feat}.name],[harshthrvals(1:4) harshgoodnessvals, corr_val])};
%             
%             reports{ comparisoncount,1} = [reports{ comparisoncount,1}, rep1];
%             reports{ comparisoncount,2} = [reports{ comparisoncount,2}, rep2];

            rep1={sprintf(['%0.2f\t%0.2f\t%0.2f\t|',...
                           ' %0.2f\t%0.2f\t%0.2f\t|',...
                           ' %0.2f\t%0.2f\t%0.2f\t|',...
                           ' %0.2f\t%0.2f\t%0.2f\t|',...
                           '\t%0.2f\t| ', num2str(feat), ' ', conf.methodlist{feat}.name],...
                           [thrvals(1:3) goodnessvals, harshthrvals(1:3) harshgoodnessvals ,corr_val])};        
            
            
            reports{ comparisoncount}  = [reports{ comparisoncount}, rep1];
            
            
            HA{comparisoncount} = subplot(3,1,comparisoncount);
            
            

            Value_difference=plot_positions{comparisoncount}{1};
            plot_pos=plot_positions{comparisoncount}{2};
            % Add miniscule noise to make values unique:
            %if feat>37
            Value_difference=Value_difference+10^-12*rand(size(Value_difference));
            %end

            
            %
            % Plot the smoothed windowed values:
            %
            %
            plot(Value_difference(goodorbad==0),plot_pos(goodorbad==0),'s','MarkerEdgeColor',[1.0, 0.7, 0.1]);
            hold on             
            plot(Value_difference(goodorbad==1),plot_pos(goodorbad==1)  ,'d','MarkerEdgeColor',[0.2, 0.6, 0.2]);
            plot(Value_difference(goodorbad==-1),plot_pos(goodorbad==-1),'ro');

            

            
            
            
            % Fit model to data using Matlab's smoothing spline.
            
            % A smoothing spline to give a rough estimate of the
            % probability of correct guesses:
            
            % Set up fittype and options.
            ft = fittype( 'smoothingspline' );
            opts = fitoptions( 'Method', 'SmoothingSpline' );
            opts.Normalize = 'on';
            opts.SmoothingParam = 0.95;

            [fitresult, gof] = fit( Value_difference(abs(goodorbad)==1), (goodorbad(abs(goodorbad)==1)+1)/2, ft, opts );

            h1 = plot(fitresult,'b');
            set(h1,'LineWidth',2);


            
            % Fit another line, this one looks at the undecided pair
            % comparisons and considers them failures:
            [fitresult2, gof] = fit( Value_difference, floor((goodorbad+1)/2), ft, opts );

            h1 = plot(fitresult2,'b--');
            set(h1,'LineWidth',2);           

            
            %
            % Let's draw the threshold boundaries on the images and label
            % them with their value and the percentage of correct data
            % "above" them.
            %
            % First for the case where we neglect the "undecided" tests:
            %
            linecolors={'b', [0.2, 0.6, 0.2], 'r', 'm', 'b', [0.2, 0.6, 0.2], 'r', 'm'};
            colorpointer=0;
            pointer=0;

            %
            % Let's not draw identical threshold boundaries on the image -
            % that's why we compare the boundary to the next one. By
            % adding a last boundary at inf we can use simpler logic here.
            %
            thrvals=[thrvals, inf];
            
            for th=interesting_thresholds
                pointer=pointer+1;
                colorpointer = colorpointer+1;
                
                if thrvals(pointer) < inf && thrvals(pointer) ~= thrvals(pointer + 1)
                    line([thrvals(pointer),thrvals(pointer)],[0,1],'color',linecolors{colorpointer},'LineWidth',2);
                    rounded=roundn(thrvals(pointer),round(log10(thrvals(pointer))-2));
                    text(thrvals(pointer),0.07*colorpointer,[num2str(th),'% ', num2str(rounded)], 'fontsize', 14, 'fontweight', 'bold');
                    
                    %annotation('textbox', [thrvals(pointer),0.07*colorpointer,0,0], 'String', [num2str(th),'% ', num2str(rounded)],'BackgroundColor',[1.0,0.95,0.95], 'EdgeColor','blue');
                end
                
            end
            
            
            %
            % ...then for the case where we consider also the undecided
            % tests.
            %
            %
            harshthrvals=[harshthrvals, inf];

            pointer=0;
            for th=interesting_thresholds
                pointer=pointer+1;
                colorpointer = colorpointer+1;
                if harshthrvals(pointer) < inf && harshthrvals(pointer) ~= harshthrvals(pointer + 1)
                    line([harshthrvals(pointer),harshthrvals(pointer)],[0,1],'color',linecolors{colorpointer},'LineWidth',2,'LineStyle','--');
                    rounded=roundn(harshthrvals(pointer),round(log10(harshthrvals(pointer))-2));
                    text(harshthrvals(pointer),0.07*colorpointer,[num2str(th),'% ', num2str(rounded)], 'fontsize', 14, 'fontweight', 'bold');
                end
            end         

            

            % if feat==max(featlist)
            if comparisoncount == 1
                legend('Undecided evaluations in NN-window',...
                       'Correct evaluations and',...
                       'Incorect evaluations in the same way',...
                       'Smoothed spline that is nicer to look at',...
                       'Vertical bars for interesting thresholds...',...
                       '...with dotted line when uncertain tests are included',...
                       2,'Location','East')
            else
                legend off
            end
            xlabel('Value difference','FontSize',12);
            ylabel('% correct significant evaluations','FontSize',12);

            grid minor
            title(regexprep([testname,comparisonname],'_',' '),'FontSize',15); 

            %
            % Plot top row histograms. Each histogram box represents 10% of
            % the data (ie. pairwise tests). Green means that the objective
            % measure nailed it, red means it failed and yellow indicates
            % that the listeners could not make a (statistically
            % significant) decision.
            %

            allvals=sort([abs(vals),abs(nonvals)])';            
            binwidth=ceil(length(allvals)/binsteps);
            
            binedges=( allvals([binwidth:binwidth:length(allvals)-1]) + allvals([binwidth+1:binwidth:length(allvals)]) ) / 2;
            binedges=[0;binedges;(allvals(length(allvals)))];
            
            sigsbinc=histc(vals(vals>0),binedges);
            negsbinc=histc(abs(vals(vals<0)),binedges);
            nonsbinc=histc(abs(nonvals),binedges);     

            bincs=[sigsbinc;nonsbinc;negsbinc];
            %bincs=[sigsbinc;zeros(size(sigsbinc));negsbinc];
            bincs=(bincs./ repmat(sum(bincs,1),3,1))*0.2;

            upedge=1.25;
            ycoords=cumsum(bincs,1);
            
            for h=1:length(binedges)-1
                if bincs(1,h) > 0
                    rectangle('Position', [binedges(h), upedge-ycoords(1,h), binedges(h+1)-binedges(h), bincs(1,h)], 'FaceColor','g')
                end
                if bincs(2,h) > 0
                    rectangle('Position', [binedges(h), upedge-ycoords(2,h), binedges(h+1)-binedges(h), bincs(2,h)], 'FaceColor','y')
                end
                if bincs(3,h) > 0
                    rectangle('Position', [binedges(h), upedge-ycoords(3,h), binedges(h+1)-binedges(h), bincs(3,h)], 'FaceColor','r')
                end
            end
            
            if (comparisoncount==1)
                xmaxval=max(xmaxval,binedges(plottable_bins+1));
            end
            
            %
            % Some outlier analysis:
            
            mu=mean(Value_difference);
            sdev=std(Value_difference);
            
            % These are the outlier values:
            outliers=find(Value_difference>mu+2*sdev);
            %
            outliervals=(alltable(outliers,1)-mu)/sdev;
            outlierclass=alltable(outliers,2);
            outlierlabs=labs_for_plot_positions{comparisoncount}(outliers);
                        
            outliers_for_analysis{feat,comparisoncount}=struct('vals',outliervals, 'class', outlierclass, 'labs', outlierlabs);
    end
    %
    % Set all subplot axis to have the same scale
    %
    
    for comparisoncount=1:3
            %H1=subplot(3,1,comparisoncount);            
            %axis([0,maxs(feat),-0.2,1]);
            set(HA{comparisoncount}, 'ylim', [0,1.25]);
            set(HA{comparisoncount}, 'xlim', [0,xmaxval]);
            %set(HA{comparisoncount},'axis',[0,xmaxval,0,1.25]);
            %ah = axes('xlim',[ 0,xmaxval ], 'ylim', [0,1.25]);
    end

    
    
    h3 = suptitle(['Proportion of correct evaluations for feat ',num2str(feat), ': ',regexprep(conf.methodlist{feat}.name,'_',' ')]);
    set(h3,'FontSize',18,'FontWeight','normal')
    
    
    featfilename=[num2str(feat),'_',regexprep(conf.methodlist{feat}.name,'\W+','_'),'_fixed_logistics.pdf'];
    resultdir=[conf.RESULT_GRAPH_DIR, regexprep(regexprep(testname,'\W+','_'),'_+','_')];
    if ~exist(resultdir, 'dir')
        mkdir (resultdir)
    end
    disp(['Writing (or at least trying) to ', resultdir,'/',featfilename]);
    export_fig('-painters','-r600','-q101',[resultdir,'/',featfilename])
end



%reporttypes={'_only_significant', '_include_nonsignificant'};

resultdir=[conf.RESULT_REPORT_DIR, regexprep(regexprep(testname,'\W+','_'),'_+','_')];   
if ~exist(resultdir, 'dir')
    mkdir (resultdir)
end    


for r=1:length(comparisontypeslist)
    fid = fopen([resultdir, '/report_',regexprep([comparisontypeslist{r}{1}],'\W+','_') ],'w');
    for i=1:length(reports{r})
        fprintf(fid,'%s\n',reports{r}{i});
    end
    fclose(fid);
end    

disp('This last bit should activate a little helper function that ')
disp('allows you to look for outliers in the plot that you have just ')
disp('drawn. If it does not activate, you can copy & paste the last ')
disp('lines of the file into the matlab console.')
 

annot=annotation('textbox', [1,1,0,0], 'String', '','BackgroundColor',[1.0,0.95,0.95], 'EdgeColor','blue');

set(hFig,'WindowButtonMotionFcn', {@display_data_label,hFig, HA, annot, plot_positions, labs_for_plot_positions});


% Keep the workspace clean! 

clear accum alllabs alltable allvals ans bad2labs bad2vals badtable bincs
clear binedges binsteps binwidth colorpointer comparisoncount 
clear comparisonname comparisontypes comptype comptypes corporalist
clear corr_data corr_data_src corr_val corr_vals correlation_data
clear fc feat featfilename fitresult fitresult2  ft gof good2lab good2vals
clear goodnessval goodnessvals goodorbad goodtable h h1 h3 
clear harshgoodnessval harshgoodnessthresh goodnessval goodnessthresh
clear histnonlabs histnons histsiglabs histsigs indexing
clear interesting_thresholds

clear labs %labs_for_plot_positions 
clear languagelist languages_in_test 
clear linecolors m maxs methods mins mu n negsbinc nn non2labs 
clear non2vals nonlabels nonlabels1 nonlabs nons nonsaccum nonsbinc 
clear nonvals opts outlierclass outlierlabs outliers 
clear outliers_for_analysis outliervals p plot_pos %plot_positions 
clear plottable_bins plottable_feats pointer r rep1 rep2 reports 
clear res rounded sdev siglabels siglabels1 sigs sigsbinc srnonvals
clear srvals systemtypeslist t test_size test_types_in_test testname

clear testtypelist th thrval thrvals upedge vals Value_difference x
clear xmaxval y ycoords z

clear harshthrvals harshthrval harshgoodnessvals good2labs corpora_in_test
clear comparisontypeslist bestguesscorrect