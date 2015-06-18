% ANALYSIS_FFT_MFCC
%
% Provides FFT-based MFCC features for computing MCD distance measure 
% in building a distance map.
% 
%
function [returnable] = analysis_fft_mfcc(varargin)

if nargin == 0
    returnable = 'fft_mfcc';

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
    
    fft_dim=params.spectrum_dim/2+1;
    hamwin=hamming(params.frame_ms*params.fs/1000);
    M = melbankm(params.mel_dim, params.spectrum_dim, params.fs, 0, 0.5, 'u');
    
    step_length=params.fs*params.step_ms/1000;
    frame_length=params.fs*params.frame_ms/1000;    
    
    %
    % 1. Do FFT:
    %
    
    spec_feas=zeros(nr_frames_test,params.spectrum_dim);
    for frame_index=1:nr_frames_test
        framestart=(frame_index-1)*step_length+1;
        audio_short = hamwin.*test_audio(framestart:framestart+frame_length-1);
        spec_feas(frame_index,:) = sqrt(abs(fft(audio_short,params.spectrum_dim)));
    end
    spec_feas=spec_feas(:,1:fft_dim);
    spec_feas=spec_feas';
    
    %
    % 2. Mel-bank the spec and do discrete cosine transform on the banks:
    %
    
    feas_test=zeros(nr_frames_test,params.mel_dim);
    
    for frame_index=1:nr_frames_test
        feas_test(frame_index,:)=dct(log(M*spec_feas(:,frame_index)+1e-20));
    end
    
    
    % Let's not save the first channel here!
    
    feas_test = feas_test(:,2:params.cep_dim);
    
    
    %
    % Return a struct with info on the (probable) speech frames:
    %   
    
    if params.usedelta == 1
        returnable = struct('features',[feas_test, deltas(feas_test',3)', deltas(deltas(feas_test',3))'],'speech_frames',speech_frames(3:(length(speech_frames)-2))-2 );
    else
        speech_frames=speech_frames(speech_frames <= length(feas_test));
        returnable = struct('features',feas_test,'speech_frames',speech_frames);
    end
    
else
    error('analysis_fft_mfcc requires 0 or 3 arguments (audio, parameters, filename).')
end