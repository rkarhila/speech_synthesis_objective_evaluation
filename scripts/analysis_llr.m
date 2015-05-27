% ANALYSIS_LLR
%
% Provides windowed audio data features for computing  Log-Likelihood Ratio
% distortion between reference and test samples
%

function [returnable] = analysis_llr(varargin)

if nargin == 0
    returnable = 'fft_melbank';

elseif nargin == 3

    local_conf

    audio_struct= varargin{1};
    
    test_audio = audio_struct.audio;
    nr_frames_test=audio_struct.nr_frames_test;
    speech_frames=audio_struct.speech_frames;
    
    params = varargin{2};

    
    filename = varargin{3}; % Not used for anything, as it is not judged 
                            % worthy to cache fft results
    
     
    %
    % 0. Get some useful variables:
    %    (could be pregenerated but aren't, guess why!)
    
    hamwin=hamming(params.frame_ms*params.fs/1000);
    
    step_length=params.fs*params.step_ms/1000;
    frame_length=params.fs*params.frame_ms/1000;    
    
    %
    % 1. Do windowing - not much to do for preparing the LLR...:
    %
    
    aux_noise=rand([frame_length,1])*exp(-60);
    feas_test=zeros(nr_frames_test,length(hamwin));
    
    for i=1:nr_frames_test
        framestart=(i-1)*step_length+1;
        feas_test(i,:) = hamwin.*test_audio(framestart:framestart+ ...
            frame_length-1);
        
        if (sum(abs(feas_test(i,:)))) == 0
            feas_test(i,:)=aux_noise;
        end
    end
    
    returnable = struct('features',feas_test,'speech_frames',speech_frames);
    
    
    
    
    
else
    error('analysis_fft_melbank requires 0 or 3 arguments (audio, parameters, filename).')
end