% likelihood calculation with gmm, calculates also correlation with sub
% scores

clear

addpath /home/uremes/ssw_matlab/include/voicebox
addpath /akulabra/projects/T40511/Modules/opt/STRAIGHT/V40_003
addpath /home/uremes/ssw_matlab/include/gmmbayestb-v1.0

num_systems=18;
num_utterances=19;

test_num_components = [5 10 30 50];  

% OBS! filepaths have not been updated

reference_sent_list_sim = '/home/uremes/ssw_matlab/devel/nat_reference.scp';
reference_sent_list_nat = '/home/uremes/ssw_matlab/devel/sim_reference.scp';

sub_scores_sim=load('/home/uremes/ssw_matlab/devel/subjective_eval_sim_means.numbers.txt');
sub_scores_nat=load('/home/uremes/ssw_matlab/devel/subjective_eval_nat_means.numbers.txt');

spec_method='straight';
test_feature_domain = 'log-mel'; % log-mel, mel-cep

model_type = 'gmm_set_diag'; % gmm_set, gmm_set_diag, mfa_set

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

for test_num=1:length(test_num_components)
    
num_components = test_num_components(test_num);

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

end



% make to distance measure

ob_scores_sim=-1*ob_scores_sim;
ob_scores_nat=-1*ob_scores_nat;
%save ('../devel/objective_results_gmm_sim','ob_scores_sim','-ascii');
%save ('../devel/objective_results_gmm_nat','ob_scores_nat','-ascii');

% evaluation 1) correlation

[cor_sim,p_sim]=corr(sub_scores_sim(:,1),ob_scores_sim)
[cor_nat,p_nat]=corr(sub_scores_nat(:,1),ob_scores_nat)

if sys_scores
[cor_sim_sys,p_sim_sys]=corr(sub_scores_sys_sim(:,1),ob_scores_sys_sim)
[cor_nat_sys,p_nat_sys]=corr(sub_scores_sys_nat(:,1),ob_scores_sys_nat)
end

% evaluation 2) classification performance

opinion_matrix = load('../blizzard_tests/2009_simrefEH2.ascii');
%evaluate_wilcoxon
%evaluate_wilcoxon(ob_scores_sim, sub_scores_sim, opinion_matrix, [])

% simple version:

class_matrix=zeros(num_systems);
for findex=1:num_systems
   class_matrix(findex,:)=sub_scores_sys_sim(findex,1)-sub_scores_sys_sim(:,1)'; 
end
class_matrix = sign(opinion_matrix.*class_matrix);
class_matrix = class_matrix(triu(ones(num_systems)-eye(num_systems))>0);

num_pairs = size(class_matrix,1); % num paired comparisons
num_classified_pairs = sum(abs(class_matrix)); % num nonzero entries

acc1=zeros(length(test_num_components),1);
acc2=zeros(length(test_num_components),1);
ucco=zeros(lentgh(test_num_components),1);


for test_num=1:length(test_num_components)
   
    % 1) AB
    
    ob_class=zeros(num_systems);
    for findex=1:num_systems
    ob_class(findex,:) = ob_scores_sys_sim(findex,test_num)-ob_scores_sys_sim(:,test_num);
    end
    ob_class = sign(ob_class);
    ob_class = ob_class(triu(ones(num_systems)-eye(num_systems))>0);
    
    num_correct = sum((class_matrix.*ob_class)>0);
    acc1(test_num) = num_correct/num_classified_pairs;
    
    % wilcoxon
    
    pmat=ones(num_systems);
    for findex=1:num_systems
        
         b1=(findex-1)*num_utterances+1;
         e1=b1+num_utterances-1;
         
         for findex2=findex+1:num_systems
         b2=(findex2-1)*num_utterances+1;
         e2=b2+num_utterances-1;
         pmat(findex,findex2) = signrank(ob_scores_sim(b1:e1,test_num)-ob_scores_sim(b2:e2,test_num));
         end 
    end
    pmat=pmat<0.05;
    ob_class = pmat(triu(ones(num_systems)-eye(num_systems))>0).*ob_class;
      
    % evaluation
    
    conf_matrix=crosstab(class_matrix,ob_class);

    h1=-1*sum(sum(conf_matrix/num_pairs,2).*log(sum(conf_matrix/num_pairs,2)));
    h2=-1*sum(sum((conf_matrix/num_pairs).*log(max(bsxfun(@times,conf_matrix,1./sum(conf_matrix)),exp(-700)))));
    
    ucco(test_num)=(h1-h2)/h1; % uncertainty coefficient (measures association between variables, non-symmatric, here we predict real class (x) from ob_class (y))
    
    num_correct = sum(diag(conf_matrix));
    acc2(test_num) = num_correct/num_pairs;
    
    % print
        
    [abs(cor_sim(test_num)) abs(cor_sim_sys(test_num)) acc1(test_num) acc2(test_num) ucco(test_num)]
end
