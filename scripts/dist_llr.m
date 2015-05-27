% DIST_LLR
%
% makes distance map between two samples based on the feature hinted
% by the name of the function
function [returnable] = dist_llr(varargin)

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

    
    
    N = 10;

    a_test=zeros(nr_frames_test,N+1);

    for i=1:nr_frames_test

        [ay,ry] = ilpc(feas_test(i,:),N);
        a_test(i,:)=ay';

    end

    a_ref=zeros(nr_frames_ref,N+1);
    R_ref=zeros(N+1,N+1,nr_frames_ref);

    %
    % Here we'll calculate the toeplitz matrices for all the frames in the
    % reference utterance:
    %
    for i=1:nr_frames_ref

        [ax,rx] = ilpc(feas_ref(i,:),N);
        a_ref(i,:) = ax;

        rx = rx/rx(1);
        R_ref(:,:,i) = toeplitz(rx);

    end


    for i=1:nr_frames_test
        for j=1:nr_frames_ref

            N = 10;

            %
            %  This would have been the code for sample by sample
            %  comparison, but we're comparing one frame of reference to
            %  each and every frame of the test utterance:
            %
            %                [ax,rx] = ilpc(x,N);
            %                [ay,ry] = ilpc(y,N);

            %rx = rx/rx(1);
            %ry = ry/ry(1);

            %  R =toeplitz(rx);

            ay=a_test(i,:)';
            ax=a_ref(j,:)';

            R=R_ref(:,:,j);

            num = ay'*R*ay;
            den = ax'*R*ax;

            distmap(i,j) = log(num/den);

        end  
    end

    
    returnable=distmap;


else
    returnable = nan;
  
end
            
            