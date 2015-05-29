function [returnable] = model_test_gmm(varargin)
    
if nargin == 0
    returnable = 'gmm_testing';
    
elseif nargin == 3
    local_conf;
    
    gmm = varargin{1};
    
    features = varargin{2};
    
    params = varargin{3};
  
    %
    % Why is this normalised with the length of test_feat?
    %
    %gmmres(i)= -sum(log(gmmb_pdf(ref_feat.features(ref_feat.speech_frames,:), par_gaussians{i}{y})+exp(-700)))/size(test_feat,1);
    %
    % Let's replace with:
    %    gmmres(index)= -sum(log(gmmb_pdf(ref_feat.features(ref_feat.speech_frames,:), par_gaussians{i}{y})+exp(-700)))/size(ref_feat,1);
    
    % No, it's time to simplify:
    
    %returnable= -sum(log(gmmb_pdf(features, gmm)+exp(-700)))/size(features,1);
    
    % Let's simpilfy even more by using voicebox:
    
    if params.cov_type=='diag'
        sigma=diag(gmm.sigma(1,:));
        for n=2:size(gmm.sigma,1)
           sigma = cat(3,sigma,diag(gmm.sigma(n,:)));
        end
    else
       sigma=gmm.sigma;
    end
    
    
    [lp,~,~,~] = gaussmixp(features, gmm.mu, sigma, gmm.weights);
    
    returnable = -mean(lp);
    
    if isnan(returnable)
        disp(['NaN while testing ', params.name]);
    end
    
else
    error('model_train_gmm takes 0 or 3 arguments (model, features and parameters)');
end