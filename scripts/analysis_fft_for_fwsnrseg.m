function [returnable] = analysis_fft_for_fwsnrseg(varargin)
%
% Provides features for using fwSNRseg distance measure 
% in building a distance map.
% 
% Essentially the features are Mel-banked FFT spectra.
%
%
if nargin == 0
    returnable = 'fft_for_fwsnr';

elseif nargin == 3

    local_conf

   
    test_audio = varargin{1};
    nr_frames_test=varargin{2};
    speech_frames=varargin{3};
     
    %
    % 0. Get some useful variables:
    %    (could be pregenerated but aren't, guess why!)
    
    fft_dim=spectrum_dim/2+1;
    hamwin=hamming(frame_ms*fs/1000);
    M = melbankm(mel_dim, spectrum_dim, fs, 0, 0.5, 'u');

    %
    % 1. Do FFT:
    %
    
    spec_feas=zeros(nr_frames_test,fft_dim);
    for frame_index=1:nr_frames_test
        framestart=(frame_index-1)*step_length+1;
        audio_short = hamwin.*test_audio(framestart:framestart+frame_length-1);
        spec_feas(frame_index,:) = sqrt(abs(fft(audio_short,fft_dim)));
    end
    
    spec_feas=spec_feas';
    
    %
    % 2. Get *normalised* Mel-banks:
    %
    
    feas_test=zeros(nr_frames_test,mel_dim);
    
    for i=1:nr_frames_test
        feas = spec_feas(:,i);
        spec_norm = bsxfun(@times, feas, 1./sum(feas));
        mel_norm=M*spec_norm;
        feas_test(i,:)=mel_norm;
    end
    
    %
    % Return a struct with info on the (probable) speech frames:
    %
    
    returnable = struct('features',feas_test,'speech_frames',speech_frames);
else
    error('analysis_fft_for_fwsnrseg requires 0 or 3 arguments.')
end