function [returnable] = dist_fwsnrseg(varargin)

if nargin == 0
    returnable = 'fwSNRseg';
    
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
        mel_norm_test=max(feas_test(i,:),exp(-700));
        for j=1:nr_frames_ref
            
            %sum(abs(feas_ref(j,:)-feas_test(i,:)))
            
            mel_norm_ref=max(feas_ref(j,:),exp(-700));
            
            W1 = power(mel_norm_ref,params.gamma1);
            S1 = 10*log10(power(mel_norm_ref,2)./power(mel_norm_ref-mel_norm_test,2)); % min: values below zero are unlikely, max: Inf
            S1 = max(min(S1,35),-10);
            cur_S1 = sum(sum(W1.*S1)./sum(W1));
            %cur_S2(windex)=-1*cur_S1;
            distmap(i,j)=cur_S1;
            
        end
        
        
        
    end
    returnable=35-distmap;


else
    returnable = nan;
  
end
            
            