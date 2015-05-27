% DIST_MCD
%
% makes distance map between two samples based on the feature hinted
% by the name of the function
function [returnable] = dist_mcd(varargin)

if nargin == 0
    returnable = 'mcd';
    
elseif nargin == 3
    local_conf;
    
    
    
    feas_test = varargin{1};
    feas_ref  = varargin{2};
    
    params = varargin{3};

    nr_frames_test=size(feas_test,1);
    nr_frames_ref=size(feas_ref,1);

    

    % Tricky bit: Make frame-by-frame distance map that is not symmetric, but
    % satisfies the constraints of global distance maps, and the
    % files are not of equal length...


    %    for sample_adjustment = -1*sample_adj_max:sample_adj_step:sample_adj_max;

    % Let's take each frame from audio1 and compare to all frames
    % of audio2

    distmap=zeros(nr_frames_test,nr_frames_ref);

    for i=1:nr_frames_test
        mcep_test=feas_test(i,:);
        for j=1:nr_frames_ref

            mcep_ref=feas_ref(j,:);
            % This used to be from (2:min(mel_dim,cep_dim+1), but the
            % first dimension is now removed already in calculate_feas
            % to make GMM training easier.
            %distmap(i,j)=sqrt(2*sum(power(mcep_test(2:min(mel_dim,cep_dim+1))-mcep_ref(2:min(mel_dim,cep_dim+1)),2)));
            %disp(min(mel_dim,cep_dim))
            %disp(size(mcep_test))
            distmap(i,j)=sqrt(2*sum(power(mcep_test-mcep_ref,2)));

        end

    end

    
    
    returnable=distmap;


else
    returnable = nan;
  
end
            
            