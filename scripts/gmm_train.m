clear

addpath /home/uremes/ssw_matlab/include/voicebox
addpath /akulabra/projects/T40511/Modules/opt/STRAIGHT/V40_003
addpath /home/uremes/ssw_matlab/include/gmmbayestb-v1.0


%cat devel/sim_evaluated.scp devel/nat_evaluated.scp | sort | uniq > devel/test_uniq.scp

test_sent_list = '/home/uremes/ssw_matlab/devel/evaluated_uniq.scp'; % synthesised speech data

make_train_data = 0;

num_systems=18;
num_utterances=38;

spec_method='straight'; % fft or straight
test_feature_domain = 'mel-cep'; % log-mel or mel-cep

if make_train_data

test_filelist = textread(test_sent_list,'%s' );
test_data = calculate_feas(test_filelist, spec_method, test_feature_domain, 1);

% make train datasets

for findex=1:num_systems
   test_data_sys{findex}=[];
   for dataindex=(findex-1)*num_utterances+1:findex*num_utterances
       test_data_sys{findex}=[test_data_sys{findex}; test_data{dataindex}];
   end
end
    
save(['train_data_' spec_method(1:2) '-' test_feature_domain], 'test_data_sys')

else

load(['train_data_' spec_method(1:2) '-' test_feature_domain])
end

% train models

for num_components=[1 5 10 15]
    
    for findex=1:num_systems
       gmm_model_set{findex}=gmmb_em(test_data_sys{findex},'components',num_components);
    end
    
    save(['gmm_set_' spec_method(1:2) '-' test_feature_domain '_' int2str(num_components) 'G'], 'gmm_model_set');

end


% for num_components=[1 5 10 15]
%     
%     for findex=1:num_systems
%        gmm_model_set{findex}=gmmb_em_d(test_data_sys{findex},'components',num_components);
%     end
%     
%     save(['gmm_set_diag_' spec_method(1:2) '-' test_feature_domain '_' int2str(num_components) 'G'], 'gmm_model_set');
% 
% end
