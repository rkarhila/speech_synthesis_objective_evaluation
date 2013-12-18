clear all

ob_scores_sim=load('devel/objective_results_sim');
ob_scores_nat=load('devel/objective_results_nat');

sub_scores_sim=load('devel/subjective_eval_sim_means.numbers.txt');
sub_scores_nat=load('devel/subjective_eval_nat_means.numbers.txt');

[cor_sim, p_sim] = corr(sub_scores_sim,ob_scores_sim);
[cor_nat, p_nat] = corr(sub_scores_nat,ob_scores_nat);

% check if data is from normal distribution

for findex=1:size(ob_scores_sim,2)
   norm_ind(1,findex)=lillietest(ob_scores_sim(:,findex));
   norm_ind(2,findex)=lillietest(ob_scores_nat(:,findex));
end

% [Yestim1, F1] = train_composite(ob_scores_sim(:,:), sub_scores_sim(:,1), 'MLR');
% num_meas=27;
% F1
% ob_scores_sim(:,num_meas+1)=-1*Yestim1;
% [Yestim1, F1] = train_composite(ob_scores_nat(:,:), sub_scores_nat(:,1), 'MLR');
% F1
% ob_scores_nat(:,num_meas+1)=-1*Yestim1;

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

[cor_sim_sys,p_sim_sys]=corr(sub_scores_sys_sim,ob_scores_sys_sim);
[cor_nat_sys,p_nat_sys]=corr(sub_scores_sys_nat,ob_scores_sys_nat);

num_data = num_systems*num_utterances;

for findex = 1:num_utterances
    
    ob_scores_norm_sim(findex:num_utterances:num_data,:)=bsxfun(@minus,ob_scores_sim(findex:num_utterances:num_data,:),mean(ob_scores_sim(findex:num_utterances:num_data,:)));
    ob_scores_norm_nat(findex:num_utterances:num_data,:)=bsxfun(@minus,ob_scores_nat(findex:num_utterances:num_data,:),mean(ob_scores_nat(findex:num_utterances:num_data,:)));
       
    sub_scores_norm_sim(findex:num_utterances:num_data,:)=bsxfun(@minus,sub_scores_sim(findex:num_utterances:num_data,:),mean(sub_scores_sim(findex:num_utterances:num_data,:)));
    sub_scores_norm_nat(findex:num_utterances:num_data,:)=bsxfun(@minus,sub_scores_nat(findex:num_utterances:num_data,:),mean(sub_scores_nat(findex:num_utterances:num_data,:)));
end

[cor_sim_norm,p_sim_norm]=corr(sub_scores_norm_sim,ob_scores_norm_sim);
[cor_nat_norm,p_nat_norm]=corr(sub_scores_norm_nat,ob_scores_norm_nat);

%[-1*cor_sim(1,:)' p_sim(1,:)'<0.05 -1*cor_sim_norm(1,:)' p_sim_norm(1,:)'<0.05 -1*cor_sim_sys(1,:)' p_sim_sys(1,:)'<0.05]

%[-1*cor_nat(1,:)' p_nat(1,:)'<0.05 -1*cor_nat_norm(1,:)' p_nat_norm(1,:)'<0.05 -1*cor_nat_sys(1,:)' p_sim_sys(1,:)'<0.05]

% rank features based on correlation

[cor_sim_sorted,cor_sim_sorted_index]=sort(abs(cor_sim(1,:)),'descend');
[cor_nat_sorted,cor_nat_sorted_index]=sort(abs(cor_nat(1,:)),'descend');

[cor_sim_norm_sorted,cor_sim_norm_sorted_index]=sort(abs(cor_sim_norm(1,:)),'descend');
[cor_nat_norm_sorted,cor_nat_norm_sorted_index]=sort(abs(cor_nat_norm(1,:)),'descend');

[cor_sim_sys_sorted,cor_sim_sys_sorted_index]=sort(abs(cor_sim_sys(1,:)),'descend');
[cor_nat_sys_sorted,cor_nat_sys_sorted_index]=sort(abs(cor_nat_sys(1,:)),'descend');

% show rank list

%[cor_sim_sorted_index' cor_sim_norm_sorted_index' cor_sim_sys_sorted_index' cor_nat_sorted_index' cor_nat_norm_sorted_index' cor_nat_sys_sorted_index']