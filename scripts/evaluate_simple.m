function [goodness] = evaluate_simple(ob_scores, sub_scores, opinion_matrix, num_systems, num_utterances)

%evaluates correlation and classification performance (without pictures)


% system-level scores

sub_scores_sys=zeros(num_systems,size(sub_scores,2));
ob_scores_sys=zeros(num_systems,size(ob_scores,2));

for findex = 1:num_systems     
    sub_scores_sys(findex,:)=mean(sub_scores((findex-1)*num_utterances+1:findex*num_utterances,:));
    ob_scores_sys(findex,:)=mean(ob_scores((findex-1)*num_utterances+1:findex*num_utterances,:));
end

% evaluation 1) correlation

[cor_utterance,p_utterance]=corr(sub_scores(:,1),ob_scores);
[cor_sys,p_sys]=corr(sub_scores_sys(:,1),ob_scores_sys);

cor_utterance=abs(cor_utterance).*(p_utterance<0.05);
cor_sys=abs(cor_sys).*(p_sys<0.05);

% evaluation 2) classification performance

class_matrix=zeros(num_systems);
for findex=1:num_systems
   class_matrix(findex,:)=sub_scores_sys(findex,1)-sub_scores_sys(:,1)'; 
end
class_matrix = sign(opinion_matrix.*class_matrix);
class_matrix = class_matrix(triu(ones(num_systems)-eye(num_systems))>0);

num_pairs = size(class_matrix,1); % num paired comparisons
num_classified_pairs = sum(abs(class_matrix)); % num nonzero entries

acc1=zeros(size(ob_scores,2),1);
acc2=zeros(size(ob_scores,2),1);
ucco=zeros(size(ob_scores,2),1);

for test_num=1:size(ob_scores,2)
   
    % 2-class
    
    ob_class=zeros(num_systems);
    for findex=1:num_systems
    ob_class(findex,:) = ob_scores_sys(findex,test_num)-ob_scores_sys(:,test_num);
    end
    ob_class = sign(ob_class);
    ob_class = ob_class(triu(ones(num_systems)-eye(num_systems))>0);
    
    num_correct = sum((class_matrix.*ob_class)>0);
    acc1(test_num) = num_correct/num_classified_pairs;
    
    % 3-class
    
    pmat=ones(num_systems);
    for findex=1:num_systems
        
         b1=(findex-1)*num_utterances+1;
         e1=b1+num_utterances-1;
         
         for findex2=findex+1:num_systems
         b2=(findex2-1)*num_utterances+1;
         e2=b2+num_utterances-1;
         pmat(findex,findex2) = signrank(ob_scores(b1:e1,test_num)-ob_scores(b2:e2,test_num));
         end 
    end
    pmat=pmat<0.05;
    ob_class = pmat(triu(ones(num_systems)-eye(num_systems))>0).*ob_class;
    
    conf_matrix=crosstab(class_matrix,ob_class);

    h1=-1*sum(sum(conf_matrix/num_pairs,2).*log(sum(conf_matrix/num_pairs,2)));
    h2=-1*sum(sum((conf_matrix/num_pairs).*log(max(bsxfun(@times,conf_matrix,1./sum(conf_matrix)),exp(-700)))));
    
    ucco(test_num)=(h1-h2)/h1; % uncertainty coefficient (measures association between variables, non-symmatric, here we predict real class (x) from ob_class (y))
    
    num_correct = sum(diag(conf_matrix));
    acc2(test_num) = num_correct/num_pairs;
    
    % print
        
    %[abs(cor_utterance(test_num)) abs(cor_sys(test_num)) acc1(test_num) acc2(test_num) ucco(test_num)]

end

goodness=[cor_utterance' cor_sys' acc1 acc2 ucco];

