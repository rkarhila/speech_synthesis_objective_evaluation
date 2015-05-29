function [returnable] = model_train_gmm(varargin)
    
if nargin == 0
    returnable = 'gmm_training';
    
elseif nargin == 2
    local_conf;
    
    x = varargin{1};
    
    params = varargin{2};

    
                    
    if (isfield(params, 'init_method'))
        v0=params.init_method;
    else
        v0='k';
    end
                    
    if (isfield(params, 'varfloor'))
        c=v0.varfloor;
    else
        c=[];
    end

    if (isfield(params, 'num_components'))
        m0=params.num_components;
    else
        m0=3;
    end
       
    if (params.cov_type=='full')
        v0=[v0,'v'];
    end

    if (isfield(params, 'stopping_criterion'))
        l=params.stopping_criterion;
    else
        l=[];
    end
    
    [m,v,w,~,f,~,~]=gaussmix(x,c,l,m0,v0);

    returnable=struct(...
     'mu',m,   ...
     'sigma',v, ...
     'weights',w',...
     'fischer_discriminant',f);
    
    
else
    error('model_train_gmm takes 0 or 2 arguments (features and parameters)');
end