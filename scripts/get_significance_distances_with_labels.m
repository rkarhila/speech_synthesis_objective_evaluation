
function [significants_by_type, non_significants_by_type, correlations_sys, bestguesscorrect, sigs_labels_by_type, nons_labels_by_type, testsize] = get_significance_distances_with_labels(testname, objective_scores, subjective_scores, opinion_matrix, systems, systemtypes, testfilelist)

bestguesscorrect=0;
sigs_labels=0;
nons_labels=0;

syscount=length(systems);
featcount=size(objective_scores,2);

testlen=size(objective_scores,1)/syscount;

bigp=cell(featcount,1);
machinemeans=zeros(syscount,featcount);

labelsystems=char(syscount,1);
for i=1:syscount
   labelsystems(i)=systems(i) ;
end

labelpairs=cell(syscount,syscount);
for i=1:syscount
    for j=1:syscount
        labelpairs{i,j} = [testname,'_',labelsystems(i), '_vs_' labelsystems(j)];
    end
end


%
% We'll gather here the mean values obtained in objective evaluation for
% each test type (called feature here for legacy reasons, let's clean the
% code some day, shall we not?):
%

for feat=1:featcount
    bigp{feat}=ones(syscount,syscount);
    for s1=1:syscount
        s1start=(s1-1)*testlen+1;
        s1end=s1*testlen;
        systemscores=objective_scores (s1start:s1end, feat );
        machinemeans(s1, feat)=nanmean( systemscores(isfinite(systemscores)) );
    end
end


%
% Then we make a matrix that shows pairwise difference between each system
% pair for each test type. For example, comparing systems B and C, with 
% reference system A, with sentences 1...N:

% machinebetters(B,C) = 
%   mean( compare A-B for sent 1...N ) - mean( compare A-C for sent 1...N )


betters=zeros(syscount);
machinebetters=cell(featcount,1);
for s1=1:syscount
    for s2=1:syscount
        betters(s1,s2)=subjective_scores(s1)-subjective_scores(s2);
        for feat=1:featcount
             machinebetters{feat}(s1,s2)=-(machinemeans(s1,feat)-machinemeans(s2,feat));             
        end
    end
end


%
% An alternative way to compare the test types ("features") is to compute
% average difference for each sentence pair and weight them in a fashion 
% that could be usefiul somehow. For example, comparing systems  B and C 
% with reference systems A, with sentences 1...n:

% pairingbetters(B,C) = 
%   mean( for sent 1...N (some function ( compare A-B )-( compare A-C ) ))

% Here we take a square of the pairwise difference.
% We're not using the code right now, but we'll leave it here as an example
% what you could do to tweak the result analysis.


if (1 == 2)

    pairingbetters=cell(featcount,1);
    for s1=1:syscount
        s1start=(s1-1)*testlen+1;
        s1end=s1*testlen;
        s1scores=objective_scores (s1start:s1end, : );
        for s2=1:syscount
            if (s1 ~= s2)
                s2start=(s2-1)*testlen+1;
                s2end=s2*testlen;
                s2scores=objective_scores (s2start:s2end, : );
                for feat=1:featcount
                    diffs=sign( s1scores(:,feat)-s2scores(:,feat)) .* (s1scores(:,feat)-s2scores(:,feat)).^2;
                    pairingbetters{feat}(s1,s2)=  -sign(mean( diffs(isfinite(diffs)))) * sqrt(abs(mean( diffs(isfinite(diffs)))));
                end
            end
        end
    end
    
    machinebetters=pairingbetters;
end

%
% We'll do the result evaluation for three categories:
% 
% 1) All systems compared to each other system
% 2) Unit selection systems compared to other unit selection systems
% 3) Statistical parametric systems compated to other parametric systems
%
% The list of system types has been composed from the Blizzard challenge
% papers, based on the brief description provided by the developers and 
% with the secret list provided by the organisers.
%
% So-called hybrid systems have been categorised as unit selection if they 
% use parts of natural speech in the final waveforms. This is again a
% little bit of guesswork based on the short technical description.
%

testsize={0,0,0};
typematrix=zeros(length(systemtypes));
for n=1:length(systemtypes)
    for m=1:n
        if systemtypes(n)=='c' && systemtypes(m)=='c' 
            typematrix(m,n)=1; % Comparison between concatenative/hybrid systems
            testsize{1}=testsize{1}+1;
            testsize{2}=testsize{2}+1;
        elseif  systemtypes(n)=='h' && systemtypes(m)=='h' 
            typematrix(m,n)=2; % Comparison between (HMM-) model-based systems
            testsize{1}=testsize{1}+1;
            testsize{3}=testsize{3}+1;
        elseif  systemtypes(n)=='c' && systemtypes(m)=='h' 
            typematrix(m,n)=3; % Cross-techniqe comparison
            testsize{1}=testsize{1}+1;
        elseif  systemtypes(n)=='h' && systemtypes(m)=='c' 
            typematrix(m,n)=3; % Cross-techniqe comparison              
            testsize{1}=testsize{1}+1;
        end
    end
end




%
% We'll be interested mostly in the comparisons of systems that have been
% judged to have a significant difference in the listening test:
%

significants_by_type=cell(1,3);
sigs_labels_by_type=cell(1,3);
%
% But we'll also check how things are with the "non-significantly"
% different systems - Mostly to see, if the differences in objective
% evaluation results are small in this case, as we'd like to suspect:
%
non_significants_by_type=cell(1,3);
nons_labels_by_type=cell(1,3);


% Loop over test types to keep track of significant and non-significant differences & correct "guess directions":
for n=1:3
    
    significant_distances=zeros(featcount, sum(sum(triu(opinion_matrix==1,1).*abs(sign(betters)).*(typematrix==n))));
    
    non_significant_distances=zeros(featcount, sum(sum(triu(opinion_matrix==0,1).*abs(sign(betters)).*(typematrix==n))));
    
    for feat = 1:featcount     
        
        if sum((machinebetters{feat}+diag(ones(length(machinebetters{feat}),1)))==0)>0
            disp(testname)
%            disp(['Some machinebetters{feat} zero for feat ',num2str(feat)]);
%            disp((machinebetters{feat}+diag(ones(length(machinebetters{feat}),1))))
%            disp(machinemeans(:,feat))

        end
        
        machinebetters{feat}(machinebetters{feat}==0)=1e-30;

        significant_diffs=triu(machinebetters{feat}.*sign(betters).*(opinion_matrix==1).*(typematrix==n),1);
        sigs_labels=labelpairs( find(triu(machinebetters{feat}.*sign(betters).*(opinion_matrix==1).*(typematrix==n),1)) );
        
        significant_diffs=significant_diffs(:)';
        
        significant_diffs=significant_diffs(significant_diffs ~= 0);
        significant_diffs(significant_diffs == 1e-30) = 0;

        significant_distances(feat,:)=significant_diffs;        
        
        non_significant_diffs=triu(machinebetters{feat}.*sign(betters).*(opinion_matrix==0).*(typematrix==n),1);

        nons_labels=labelpairs( find (triu(machinebetters{feat}.*sign(betters).*(opinion_matrix==0).*(typematrix==n),1)));
        
        non_significant_diffs=non_significant_diffs(:)';
        non_significant_diffs=non_significant_diffs(non_significant_diffs ~= 0);
        non_significant_diffs(non_significant_diffs == 1e-30) = 0;

        non_significant_distances(feat,:)=non_significant_diffs;

    end
    
    significants_by_type{n}=significant_distances;
    sigs_labels_by_type{n} = sigs_labels;
    
    non_significants_by_type{n}=non_significant_distances;
    nons_labels_by_type{n} = nons_labels;

end


%
%
%    CORRELATIONS
%
%    Incorporate to code above when a suitable occassion arises:
%
%

% Loop over test types to calculate simple correlations between subjective
% and objective scores:
        
% system-level scores

ob_scores_sys=zeros(syscount,featcount);
for i=1:syscount
    for j=1:featcount
        ob_scores_sys(i,j)=mean(objective_scores((i-1)*testlen+1:(i)*testlen,j));
    end
end
%num_utterances = testlen;

correlations_sys={};

types = {'c','h'};

%
% We want to get some simple correlation data between objective and
% subjective scores.
%
% So... 
%
% Turns out that it does not make any sense to do it based on a single
% test. So we'll just gather the related data here and pass it on to the
% caller function, where something will be done with it.
%
% So... 2.0
%
% Turns out that the correlations suck when taken over all the tests (as
% they are not in the same scale) so let's revert back to the original
% scheme.
%

for n=1:2  
    
    sub_scores = subjective_scores(systemtypes==types{n});   
    ob_scores =ob_scores_sys(find(systemtypes==types{n}),:);
    
    % Old lines to compute correlations; Let's remove these later:
    [cor_sys,p_sys]=corr(sub_scores,ob_scores);
    %abs(cor_sys)
    %cor_sys=abs(cor_sys).*(p_sys<0.05);
    correlations_sys{n+1}=cor_sys;
    %correlations_sys{n}=[sub_scores,ob_scores];
end   

% Old lines to compute correlations; Let's remove these later:
[cor_sys,p_sys]=corr(subjective_scores,ob_scores_sys);
%cor_sys=abs(cor_sys).*(p_sys<0.05);
%
correlations_sys{1}=cor_sys;

%correlations_sys{3}=[subjective_scores,ob_scores_sys];




%
% Did any of the methods make the right prediction about the winner?
%
% What was the position of the "winner" (yes, I know, I should not use such
% a term for the Blizzard results) system or systems?
%

bestguesscorrect=cell(3);
for n=1:3  
    bestguesscorrect{n}=zeros(featcount,1);

    %
    % Reduce the space we're looking at:
    %
    if n<3
        subjective_scores_part=subjective_scores(systemtypes==types{n});
        machinemeans_part=machinemeans(systemtypes==types{n},:);
    else        
        subjective_scores_part=subjective_scores;
        machinemeans_part=machinemeans;
    end
    
    %
    % Find the best system(s) in the reduced space
    %
    bestsystem=find(subjective_scores_part==max(subjective_scores_part));
    
    %
    % For each test, find the 
    %
    %disp(['bestystems for testtype ', num2str(n),': ',num2str(bestsystem),' (',num2str(subjective_scores_part(bestsystem)),')' ] );
    
    
    for feat=1:featcount        
        bestmachinesystems=find(machinemeans_part(:, feat)==max(machinemeans_part(:, feat)));
        %disp(['feat ',num2str(feat),' bestmachinesystems: ',num2str(bestmachinesystems),' (',...
        %    num2str(machinemeans_part(bestsystem,feat)),', mean ',num2str(mean(machinemeans_part(:, feat))),')' ]);
        
        
        if ismember(bestmachinesystems,bestsystem)
            bestguesscorrect{n}(feat)=1;
        end
    end
end
    
disp('done')

