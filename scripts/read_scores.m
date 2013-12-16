ob_scores_sim=load('devel/objective_results_sim');
ob_scores_nat=load('devel/objective_results_nat');

sub_scores_sim=load('devel/subjective_eval_sim_means.numbers.txt');
sub_scores_nat=load('devel/subjective_eval_nat_means.numbers.txt');

num_systems = 18;
num_utterances = 19;

for findex = 1:num_systems
    
    ob_scores_sys_sim(findex,:)=mean(ob_scores_sim((findex-1)*num_utterances+1:findex*num_utterances,:));
    ob_scores_sys_nat(findex,:)=mean(ob_scores_nat((findex-1)*num_utterances+1:findex*num_utterances,:));
       
    sub_scores_sys_sim(findex,:)=mean(sub_scores_sim((findex-1)*num_utterances+1:findex*num_utterances,:));
    sub_scores_sys_nat(findex,:)=mean(sub_scores_nat((findex-1)*num_utterances+1:findex*num_utterances,:));
    
    ob_scores_syssed_sim(findex,:)=std(ob_scores_sim((findex-1)*num_utterances+1:findex*num_utterances,:))/sqrt(num_utterances);
    ob_scores_syssed_nat(findex,:)=std(ob_scores_nat((findex-1)*num_utterances+1:findex*num_utterances,:))/sqrt(num_utterances);
       
    sub_scores_syssed_sim(findex,:)=std(sub_scores_sim((findex-1)*num_utterances+1:findex*num_utterances,:))/sqrt(num_utterances);
    sub_scores_syssed_nat(findex,:)=std(sub_scores_nat((findex-1)*num_utterances+1:findex*num_utterances,:))/sqrt(num_utterances);
end


for findex = 1:19
    
    ob_scores_norm_sim(findex:19:342,:)=bsxfun(@minus,ob_scores_sim(findex:19:342,:),mean(ob_scores_sim(findex:19:342,:)));
    ob_scores_norm_nat(findex:19:342,:)=bsxfun(@minus,ob_scores_nat(findex:19:342,:),mean(ob_scores_nat(findex:19:342,:)));
       
    sub_scores_norm_sim(findex:19:342,:)=bsxfun(@minus,sub_scores_sim(findex:19:342,:),mean(sub_scores_sim(findex:19:342,:)));
    sub_scores_norm_nat(findex:19:342,:)=bsxfun(@minus,sub_scores_nat(findex:19:342,:),mean(sub_scores_nat(findex:19:342,:)));
end