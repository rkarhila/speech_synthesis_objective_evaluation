function [returnable] = model_train_gmm(varargin)
    
if nargin == 0
    returnable = 'gmm_training';
    
elseif nargin == 2
    local_conf;

    
    x = varargin{1};
    
    params = varargin{2};

    gauss_retr=25;
    
    tries=0;
    num_components=params.num_components;
    
    while tries < gauss_retr
        try
            if params.cov_type=='full'
                gmm_model_set=gmmb_em(x,'components',num_components);
                disp(['Done in ',num2str(tries),' tries with ',num2str(num_components),' components! ',params.name]);
                tries=gauss_retr;
            else
                gmm_model_set=gmmb_em_d(x,'components',num_components);
                disp(['Done in ',num2str(tries),' tries with ',num2str(num_components),' components! ',params.name]);
                tries=gauss_retr;
            end
        catch me
            disp(me.message)

            if (num_components>35)
                num_components=num_components-3;
            else
                tries=tries+1;
            end
            
            
            disp(['Retrying ',num2str(tries),' tries', num2str(num_components),' components!',params.name]);
            if tries==gauss_retr
                tmpname=['/tmp/',regexprep(params.name,'\W+','_'),'_',datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'),'.dump'];
                parsave(tmpname,x);
                error([me.message, ' Singular gaussian! ', params.name , ' data dumped to ',tmpname,'.mat' ]);
                
            end
        end
    end
    
    returnable=gmm_model_set;
    

else
    error('model_train_gmm takes 0 or 2 arguments (features and parameters)');
end