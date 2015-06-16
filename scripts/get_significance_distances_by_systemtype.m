%
%
%   OBSOLETE
%
%   at least I think it should be.
%   Will be removed in a future version soon...
%
function [significants_by_type, non_significants_by_type, correlations_sys, bestguesscorrect] = get_significance_distances_by_systemtype(testname, objective_scores, subjective_scores, opinion_matrix, systems, systemtypes)

bestguesscorrect=0;

syscount=length(systems);
featcount=size(objective_scores,2);

testlen=size(objective_scores,1)/syscount;

bigp=cell(featcount,1);
machinemeans=zeros(syscount,featcount);

labelsystems=char(syscount,1);
for i=1:syscount
   labelsystems(i)=systems(i) ;
end


for feat=1:featcount
    bigp{feat}=ones(syscount,syscount);
    for s1=1:syscount
        s1start=(s1-1)*testlen+1;
        s1end=s1*testlen;
        systemscores=objective_scores (s1start:s1end, feat );
        machinemeans(s1, feat)=mean( systemscores(isfinite(systemscores)) );
    end
end

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




typematrix=zeros(length(systemtypes));
for n=1:length(systemtypes)
    for m=1:n
        if systemtypes(n)=='c' && systemtypes(m)=='c' 
            typematrix(m,n)=1; % Comparison between concatenative/hybrid systems
        elseif  systemtypes(n)=='h' && systemtypes(m)=='h' 
            typematrix(m,n)=2; % Comparison between (HMM-) model-based systems
        elseif  systemtypes(n)=='c' && systemtypes(m)=='h' 
            typematrix(m,n)=3; % Cross-techniqe comparison
        elseif  systemtypes(n)=='h' && systemtypes(m)=='c' 
            typematrix(m,n)=3; % Cross-techniqe comparison              
        end
    end
end

significants_by_type=cell(1,3);
non_significants_by_type=cell(1,3);

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

        significant_diffs=significant_diffs(:)';
        significant_diffs=significant_diffs(significant_diffs ~= 0);
        significant_diffs(significant_diffs == 1e-30) = 0;

        significant_distances(feat,:)=significant_diffs;

        non_significant_diffs=triu(machinebetters{feat}.*sign(betters).*(opinion_matrix==0).*(typematrix==n),1);
        non_significant_diffs=non_significant_diffs(:)';
        non_significant_diffs=non_significant_diffs(non_significant_diffs ~= 0);
        non_significant_diffs(non_significant_diffs == 1e-30) = 0;

        non_significant_distances(feat,:)=non_significant_diffs;

    end
    
    significants_by_type{n}=significant_distances;
    non_significants_by_type{n}=non_significant_distances;
    
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



for n=1:2  
    
    
    
    sub_scores = subjective_scores(systemtypes==types{n});
   
    ob_scores =ob_scores_sys(find(systemtypes==types{n}),:);

    [cor_sys,p_sys]=corr(sub_scores,ob_scores);
    %abs(cor_sys)
    %cor_sys=abs(cor_sys).*(p_sys<0.05);
    correlations_sys{n}=cor_sys;
end   

[cor_sys,p_sys]=corr(subjective_scores,ob_scores_sys);

cor_sys=abs(cor_sys).*(p_sys<0.05);

correlations_sys{3}=cor_sys;

%correlations_sys{1}

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

