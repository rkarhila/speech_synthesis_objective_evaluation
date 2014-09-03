function [significant_distances, non_significant_distances] = get_significance_distances(objective_scores, subjective_scores, opinion_matrix, systems)

listeningmeans=subjective_scores;
refmat=opinion_matrix;
refscores=objective_scores;


opinion_matrix

invdiag=ones(size(refmat))-diag(ones(size(refmat,1),1));

syscount=length(systems);
featcount=size(refscores,2);

testlen=length(subjective_scores);

testlen=size(objective_scores,1)/length(systems)

bigp=cell(size(refscores,2),1);
machinemeans=zeros(syscount,featcount);

labelsystems=char(length(systems),1);
for i=1:length(systems)
   labelsystems(i)=systems(i) ;
end

%labelsystems(length(labelsystems)+1)='.';

for feat=1:size(refscores,2)
    bigp{feat}=ones(length(systems),length(systems));
    for s1=1:length(systems)
        s1start=(s1-1)*testlen+1;
        s1end=s1*testlen;
        systemscores=refscores (s1start:s1end, feat );
        machinemeans(s1, feat)=mean( systemscores(isfinite(systemscores)) );
    end
end

betters=zeros(length(systems));
machinebetters=cell(featcount,1);
for s1=1:length(systems)
    for s2=1:length(systems)
        betters(s1,s2)=listeningmeans(s1)-listeningmeans(s2);
        for feat=1:featcount
             machinebetters{feat}(s1,s2)=-(machinemeans(s1,feat)-machinemeans(s2,feat));
        end
    end
end


triu(refmat==0)
betters

significant_distances=zeros(size(refscores,2), sum(sum(triu(refmat==1,1).*abs(sign(betters)))));

non_significant_distances=zeros(size(refscores,2), sum(sum(triu(refmat==0,1).*abs(sign(betters)))));


for feat = 1:featcount        
    machinebetters{feat}(machinebetters{feat}==0)=1e-30;
         
    machinebetters{feat}
    
    directionmatch = triu(sign(machinebetters{feat}).*sign(betters)) ;
    
    
    significant_diffs=triu(machinebetters{feat}.*sign(betters).*(refmat==1),1);
    significant_diffs=significant_diffs(:)';
    significant_diffs=significant_diffs(significant_diffs ~= 0);
    significant_diffs(significant_diffs == 1e-30) = 0;

    significant_distances(feat,:)=significant_diffs;

    non_significant_diffs=triu(machinebetters{feat}.*sign(betters).*(refmat==0),1);
    non_significant_diffs=non_significant_diffs(:)';
    non_significant_diffs=non_significant_diffs(non_significant_diffs ~= 0);
    non_significant_diffs(non_significant_diffs == 1e-30) = 0;
    
    non_significant_distances(feat,:)=non_significant_diffs;
    
end



disp('done')

