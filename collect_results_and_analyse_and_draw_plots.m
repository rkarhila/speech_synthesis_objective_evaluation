

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


plots_to_be_drawn=[1:length(testlist)];

interesting_thresholds=[50,75,90,95];

res=struct(...
    'all', struct(...
           'non_significant_values',{{}},...
           'significant_values',{{}},...
           'mins',[],...
           'maxs',[],...
           'speakers',{{}},...
           'performances', {{}}, ...
           'best_shots',{{}}),...
    'only_unitsel', struct(...
           'non_significant_values',{{}},...
           'significant_values',{{}},...
           'mins',[],...
           'maxs',[],...
           'speakers',{{}},...
           'performances', {{}}, ...
           'best_shots',{{}}), ...      
    'only_hmm', struct(...
           'non_significant_values',{{}},...
           'significant_values',{{}},...
           'mins',[],...
           'maxs',[],...
           'speakers',{{}},...
           'performances', {{}}, ...
           'best_shots',{{}}));

       

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
            [sigs, nons, correlations_sys, bestguesscorrect, siglabels1, nonlabels1] = ...
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
                
                res.(comptype).performances{n}=correlations_sys{comparisoncount};
                res.(comptype).best_shot{n}=bestguesscorrect{comparisoncount};                    
                    
                


            
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

binsteps=10;


%test_stats=struct('thresholds',[], 'data_over_thresh',[],...
%                  'harsh_thresholds',[], 'harsh_data_over_thresh',[]);

test_stats=struct('all',struct('thresholds',[], 'data_over_thresh',[],...
                  'harsh_thresholds',[], 'harsh_data_over_thresh',[]),...
                  'only_unitsel', struct('thresholds',[], 'data_over_thresh',[],...
                  'harsh_thresholds',[], 'harsh_data_over_thresh',[]),...
                  'only_hmm',  struct('thresholds',[], 'data_over_thresh',[],...
                  'harsh_thresholds',[], 'harsh_data_over_thresh',[]) );

              
%%%% For all feats? No, just for the selected ones:

plottable_feats=[18];

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
    
    smoothed_vals=cell(3,1);
    labs_for_smoothed_vals=cell(3,1);
    
    for comparisoncount=1:3                    
        comptype=comptypes{comparisoncount};

%        for testtype=0:1
        
            comparisonname=comparisontypeslist{comparisoncount}{1};

            testname=[strjoin(corpora_in_test,', '),'; ',strjoin(languages_in_test,', '),'; ',strjoin(test_types_in_test,', '),': '];

            sigs=res.(comptype).significant_values;
            
            siglabels=res.(comptype).significant_values_labels;
            
            nons=res.(comptype).non_significant_values;
            
            nonlabels=res.(comptype).non_significant_values_labels;
            
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
            x=zeros(size(z));

            for i=1:length(z)
                x(i)=sum(alltable(max(1,i-nn):min(i+nn,length(z)),2)==1)/( min(i+nn,length(z))-max(1,i-nn)+1 );
            end

            %
            % Interpolate the non-significant test values into the smoothed
            % line:
            %
            
            interpnonx=interp1(z,x,min(max(non2vals, min(z)),max(z)),'linear');
              
 
            
            alltable=[alltable; [ non2vals', zeros(size(non2vals'))]];
            alllabs=[alllabs; non2labs];
            
            [alltable, indexing]=sortrows(alltable,1);
            alllabs=alllabs(indexing);
 
            z=alltable(:,1);
            x=[x;interpnonx'];
            x=x(indexing);
            
            smoothed_vals{comparisoncount}={z,x};
            labs_for_smoothed_vals{comparisoncount}=alllabs;
            goodorbad=alltable(:,2);
            
            srvals=sort(vals);            
            srnonvals=sort(nonvals);

            accum=zeros(size(srvals));
            nonsaccum=zeros(sum(srvals>0),1);

            %ct=0;
            for m=min(find(srvals>0)):length(srvals)
                %ct=ct+1;
                accum(m)=sum((srvals>srvals(m)))/(sum((srvals>srvals(m)))+sum((srvals<(-srvals(m)))));
                nonsaccum(m)=sum((srvals>srvals(m)))/(  sum(srvals>srvals(m)) + sum(srvals<(-srvals(m))) + sum(srnonvals<(-srvals(m))) + sum(srnonvals>srvals(m))  );
            end

            theoretical_best_possible=length(vals)/(length(vals)+length(nonvals));
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
                  
                  harshgoodnessval=(1-(min(find(nonsaccum> (th/100)))/length(nonsaccum)))/theoretical_best_possible;
                  if (isempty(harshgoodnessval))
                    harshgoodnessval=0;
                  end              
                  harshgoodnessvals(pointer)=harshgoodnessval;

                  
             end
             
             
                 
            disp([testname, comparisonname, '  thresholds 50/75/90/95:']);
            disp([thrvals; goodnessvals]);
            disp([testname, comparisonname, '  thresholds 50/75/90/95, including undecided: ']);
            disp([harshthrvals; harshgoodnessvals]);
            
            
            
            test_stats.(comptype).thresholds(feat,:)=thrvals;
            test_stats.(comptype).harsh_thresholds(feat,:)=harshthrvals;
            
            test_stats.(comptype).data_over_thresh(feat,:)=goodnessvals;
            test_stats.(comptype).harsh_data_over_thresh(feat,:)=harshgoodnessvals;
            
            
            
            HA{comparisoncount} = subplot(3,1,comparisoncount);
            
            

            Value_difference=smoothed_vals{comparisoncount}{1};
            Smoothed_probability=smoothed_vals{comparisoncount}{2};
            % Add miniscule noise to make values unique:
            %if feat>37
            Value_difference=Value_difference+10^-12*rand(size(Value_difference));
            %end

            
            %
            % Plot the smoothed windowed values:
            %
            %
            plot(Value_difference(goodorbad==0),Smoothed_probability(goodorbad==0),'s','MarkerEdgeColor',[1.0, 0.7, 0.1]);
            hold on             
            plot(Value_difference(goodorbad==1),Smoothed_probability(goodorbad==1),'d','MarkerEdgeColor',[0.2, 0.6, 0.2]);
            plot(Value_difference(goodorbad==-1),Smoothed_probability(goodorbad==-1),'ro');

            

            
            
            
            % Fit model to data using Matlab's smoothing spline.
            
            % A smoothing spline to give a rough estimate of the
            % probability of correct guesses:
            
            % Set up fittype and options.
            ft = fittype( 'smoothingspline' );
            opts = fitoptions( 'Method', 'SmoothingSpline' );
            opts.Normalize = 'on';
            opts.SmoothingParam = 0.95;

            [fitresult, gof] = fit( Value_difference, Smoothed_probability, ft, opts );

            h1 = plot(fitresult,'b');
            set(h1,'LineWidth',2);


                        

            
            %
            % Let's draw the threshold boundaries on the images and label
            % them with their value and the percentage of correct data
            % "above" them.
            %
            % First for the case where we neglect the "undecided" tests:
            %
            linecolors={'b', 'g', 'r', 'm', 'b', 'g', 'r', 'm'};
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
                    line([thrvals(pointer),thrvals(pointer)],[0,1],'color',char(linecolors{colorpointer}),'LineWidth',2);
                    rounded=roundn(thrvals(pointer),round(log10(thrvals(pointer))-2));
                    text(thrvals(pointer),0.07*colorpointer,[num2str(th),'% ', num2str(rounded)]);
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
                    text(harshthrvals(pointer),0.07*colorpointer,[num2str(th),'% ', num2str(rounded)]);
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
            title([testname,', ',comparisonname],'FontSize',15); 

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
                if bincs(3,h)
                    rectangle('Position', [binedges(h), upedge-ycoords(3,h), binedges(h+1)-binedges(h), bincs(3,h)], 'FaceColor','r')
                end
            end

            xmaxval=max(xmaxval,max(allvals));
            

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

    
    
    h3 = suptitle(['Proportion of correct evaluations for feat ',num2str(feat), ': ',testlist{feat}.name]);
    set(h3,'FontSize',18,'FontWeight','normal')
    
    
    featfilename=[num2str(feat),'_',regexprep(testlist{feat}.name,'\W+','_'),'_fixed_logistics.pdf'];
    export_fig('-painters','-r600','-q101',[RESULT_GRAPH_DIR,featfilename])
end




disp('This last bit should activate a little helper function that ')
disp('allows you to look for outliers in the plot that you have just ')
disp('drawn. If it does not activate, you can copy & paste the last ')
disp('lines of the file into the matlab console.')
 

annot=annotation('textbox', [1,1,0,0], 'String', '','BackgroundColor',[1.0,0.95,0.95], 'EdgeColor','blue');

set(hFig,'WindowButtonMotionFcn', {@display_data_label,hFig, HA, annot, smoothed_vals, labs_for_smoothed_vals});

