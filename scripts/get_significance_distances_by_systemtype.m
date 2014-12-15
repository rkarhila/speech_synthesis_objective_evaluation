% <<<<<<< HEAD
% function [significants_by_type, non_significants_by_type] = get_significance_distances_by_systemtype(testname,objective_scores, subjective_scores, opinion_matrix, systems, systemtypes)
% 
% listeningmeans=subjective_scores;
% refmat=opinion_matrix;
% refscores=objective_scores;
% 
% %opinion_matrix;
% %invdiag=ones(size(refmat))-diag(ones(size(refmat,1),1));
% 
% syscount=length(systems);
% featcount=size(refscores,2);
% 
% %testlen=length(subjective_scores);
% =======
function [significants_by_type, non_significants_by_type, correlations_utt, correlations_sys, bestguesscorrect] = get_significance_distances_by_systemtype(objective_scores, subjective_scores, opinion_matrix, systems, systemtypes)

bestguesscorrect=0;

syscount=length(systems);
featcount=size(objective_scores,2);
% >>>>>>> 5eeaa601b37a34588d5120bec85fddd2f5cc1653

testlen=size(objective_scores,1)/length(systems);

bigp=cell(size(objective_scores,2),1);
machinemeans=zeros(syscount,featcount);

labelsystems=char(length(systems),1);
for i=1:length(systems)
   labelsystems(i)=systems(i) ;
end


for feat=1:size(objective_scores,2)
    bigp{feat}=ones(length(systems),length(systems));
    for s1=1:length(systems)
        s1start=(s1-1)*testlen+1;
        s1end=s1*testlen;
        systemscores=objective_scores (s1start:s1end, feat );
        machinemeans(s1, feat)=mean( systemscores(isfinite(systemscores)) );
    end
end

betters=zeros(length(systems));
machinebetters=cell(featcount,1);
for s1=1:length(systems)
    for s2=1:length(systems)
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
    
    significant_distances=zeros(size(objective_scores,2), sum(sum(triu(opinion_matrix==1,1).*abs(sign(betters)).*(typematrix==n))));
    non_significant_distances=zeros(size(objective_scores,2), sum(sum(triu(opinion_matrix==0,1).*abs(sign(betters)).*(typematrix==n))));
    
    for feat = 1:featcount     
        
        if sum((machinebetters{feat}+diag(ones(length(machinebetters{feat}),1)))==0)>0
            disp(testname)
%            disp(['Some machinebetters{feat} zero for feat ',num2str(feat)]);
%            disp((machinebetters{feat}+diag(ones(length(machinebetters{feat}),1))))
%            disp(machinemeans(:,feat))

        end
        
        machinebetters{feat}(machinebetters{feat}==0)=1e-30;

%<<<<<<< HEAD
%        machinebetters{feat};

        %directionmatch = triu(sign(machinebetters{feat}).*sign(betters)) ;    

%        significant_diffs=triu(machinebetters{feat}.*sign(betters).*(refmat==1).*(typematrix==n),1);
%=======
        significant_diffs=triu(machinebetters{feat}.*sign(betters).*(opinion_matrix==1).*(typematrix==n),1);
%>>>>>>> 5eeaa601b37a34588d5120bec85fddd2f5cc1653
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


% Loop over test types to calculate simple correlations between subjective
% and objective scores:
        
% system-level scores

sub_scores_sys=zeros(syscount,size(subjective_scores,2)); % num system x num subjective evaluations
ob_scores_sys=zeros(syscount,size(objective_scores,2));

%num_utterances = testlen;

for findex = 1:syscount     
    sub_scores_sys(findex,:)=mean(subjective_scores((findex-1)*testlen+1:findex*testlen,:));
    ob_scores_sys(findex,:)=mean(objective_scores((findex-1)*testlen+1:findex*testlen,:));
end

types = {'c','h'};

for n=1:2  

    sub_scores = subjective_scores(systemtypes==types(n));
    ob_scores =objective_scores(systemtypes==types(n));
    
    [cor_utterance,p_utterance]=corr(sub_scores(:,1),ob_scores);
    [cor_sys,p_sys]=corr(sub_scores_sys(:,1),ob_scores_sys);

    cor_utterance=abs(cor_utterance).*(p_utterance<0.05);
    cor_sys=abs(cor_sys).*(p_sys<0.05);
    
    correlations_utt{n}=cor_utterance;
    correlations_sys{n}=cor_sys;
end   

[cor_utterance,p_utterance]=corr(subjective_scores(:,1),objective_scores);
[cor_sys,p_sys]=corr(sub_scores_sys(:,1),ob_scores_sys);

cor_utterance=abs(cor_utterance).*(p_utterance<0.05);
cor_sys=abs(cor_sys).*(p_sys<0.05);

correlations_utt{3}=cor_utterance;
correlations_sys{3}=cor_sys;

    
disp('done')

