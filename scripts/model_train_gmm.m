function [returnable] = model_train_gmm(varargin)
    
if nargin == 0
    returnable = 'gmm_training';
    
elseif nargin == 2
    local_conf;
    
    test_data_sys = varargin{1};
    
    params = varargin{2};

    
    tries=0
    while tries < params.gauss_retr
        try
            if params.cov_type=='diag'
                [returnable, ~]=gmmb_em_d(test_data_sys,'components',params.num_components);
            else
                [returnable, ~]=gmmb_em(test_data_sys,'components',params.num_components);
            end
            tries= params.gauss_retr;
        catch me
            tries=tries+1;
            if tries==params.gauss_retr
                error('Singular gaussian!');
            end
        end
    end
else
    error('model_train_gmm takes 0 or 2 arguments (features and parameters)');
end