% likelihood calculation with gmm, calculates also correlation with sub
% scores

%clear

addpath /home/uremes/ssw_matlab/include/voicebox
addpath /akulabra/projects/T40511/Modules/opt/STRAIGHT/V40_003
addpath /home/uremes/ssw_matlab/include/gmmbayestb-v1.0

num_systems=18;
num_utterances=19;

% OBS! filepaths have not been updated

reference_sent_list_sim = '/home/uremes/ssw_matlab/devel/nat_reference.scp';
reference_sent_list_nat = '/home/uremes/ssw_matlab/devel/sim_reference.scp';

sub_scores_sim=load('/home/uremes/ssw_matlab/devel/subjective_eval_sim_means.numbers.txt');
sub_scores_nat=load('/home/uremes/ssw_matlab/devel/subjective_eval_nat_means.numbers.txt');

spec_method='straight';
test_feature_domain = 'log-mel';

model_type = 'gmm_set'; % gmm_set, gmm_set_diag, in future could be pca/mfa set too

make_ref_data = 0;
sys_scores=1;

if sys_scores

for findex = 1:num_systems
       
    sub_scores_sys_sim(findex,:)=mean(sub_scores_sim((findex-1)*num_utterances+1:findex*num_utterances,:));
    sub_scores_sys_nat(findex,:)=mean(sub_scores_nat((findex-1)*num_utterances+1:findex*num_utterances,:));
end

end

if make_ref_data

filelist = textread(reference_sent_list_sim,'%s' );
ref_data_sim = calculate_feas(filelist, spec_method, test_feature_domain, 1);

filelist = textread(reference_sent_list_nat,'%s' );
ref_data_nat = calculate_feas(filelist, spec_method, test_feature_domain, 1);

save(['ref_data_' spec_method(1:2) '-' test_feature_domain], 'ref_data_sim', 'ref_data_nat');

else
    
load(['ref_data_' spec_method(1:2) '-' test_feature_domain]);

end

if sys_scores

ref_data_sys_sim=[];
ref_data_sys_nat=[];

for uindex=1:num_utterances
    ref_data_sys_sim=[ref_data_sys_sim; ref_data_sim{uindex}];
    ref_data_sys_nat=[ref_data_sys_nat; ref_data_nat{uindex}];
end
end

% evaluate gmm likelihoods

test_num=1;

for num_components = [30]

load([model_type '_' spec_method(1:2) '-' test_feature_domain '_' int2str(num_components) 'G']);
   
for findex=1:num_systems
    
    for uindex=1:num_utterances
        for n=1:length(ref_data_sim{uindex})
            ob_scores_temp(n)=log(gmmb_pdf(ref_data_sim{uindex}(n,:),gmm_model_set{findex})+exp(-700));
        end
        ob_scores_sim((findex-1)*num_utterances+uindex,test_num)=sum(ob_scores_temp/size(ref_data_sim{uindex},1));
        
        for n=1:length(ref_data_nat{uindex})
            ob_scores_temp(n)=log(gmmb_pdf(ref_data_nat{uindex}(n,:),gmm_model_set{findex})+exp(-700));
        end
        ob_scores_nat((findex-1)*num_utterances+uindex,test_num)=sum(ob_scores_temp/size(ref_data_nat{uindex},1));
    end
    
    if sys_scores
    ob_scores_sys_sim(findex,test_num)=sum(log(gmmb_pdf(ref_data_sys_sim,gmm_model_set{findex})+exp(-700))/size(ref_data_sys_sim,1));
    ob_scores_sys_nat(findex,test_num)=sum(log(gmmb_pdf(ref_data_sys_nat,gmm_model_set{findex})+exp(-700))/size(ref_data_sys_nat,1));
    end
end

test_num=test_num+1;

end

[cor_sim,p_sim]=corr(sub_scores_sim(:,1),ob_scores_sim)
[cor_nat,p_nat]=corr(sub_scores_nat(:,1),ob_scores_nat)

if sys_scores
[cor_sim_sys,p_sim_sys]=corr(sub_scores_sys_sim(:,1),ob_scores_sys_sim)
[cor_nat_sys,p_nat_sys]=corr(sub_scores_sys_nat(:,1),ob_scores_sys_nat)
end

return

cd /home/uremes/ssw_matlab/

ob_scores_sim=-1*ob_scores_sim;
ob_scores_nat=-1*ob_scores_nat;
save ('devel/objective_results_sim','ob_scores_sim','-ascii');
save ('devel/objective_results_nat','ob_scores_nat','-ascii');
evaluate_wilcoxon
