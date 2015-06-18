%ANALYSIS_STRAIGHT_FOR_FWSNRSEG
%
% Provides features for using fwSNRseg distance measure 
% in building a distance map.
% 
% Essentially the features are Mel-banked FFT spectra.
%

function [returnable] = analysis_straight_for_fwsnrseg(varargin)

if nargin == 0
    returnable = 'straight_for_fwsnr';

elseif nargin == 3

    audio_struct= varargin{1};
    
    test_audio = audio_struct.audio;
    nr_frames_test=audio_struct.nr_frames_test;
    speech_frames=audio_struct.speech_frames;
    
    params = varargin{2};
    
    filename = varargin{3}; % Not used for anything, as it is not judged 
                            % worthy to cache fft results
    itsok=0;

    if (isfield(params, 'cache_spectrum') && params.cache_spectrum == 1)
        % STRAIGHT extraction takes some time, so let's cache the
        % feature files
        stfilename=[filename,'.params_', num2str(params.spectrum_dim)];

        if exist([stfilename,'.mat'], 'file')
            try
                spec_feas = parload(stfilename);
                itsok=1;
            catch
                itsok=0;
            end
        end

        if itsok~=1
            [f0raw,~,analysisParams]=exstraightsource(test_audio,params.fs,params);
            [spec_feas,analysisParamsSp]=exstraightspec(test_audio,f0raw,params.fs,params);

            parsave(stfilename, spec_feas);
        end

    else

        [f0raw,~,analysisParams]=exstraightsource(test_audio,params.fs,prm);
        [spec_feas,analysisParamsSp]=exstraightspec(test_audio,f0raw,params.fs,prm);

    end
    
    
    %
    % 2. Get normalised and mel-weighted spectrum:
    %
    
    M = melbankm(params.mel_dim, params.spectrum_dim, params.fs, 0, 0.5, 'u');
        
    feas_test=zeros(nr_frames_test,params.mel_dim);
    
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
    error('analysis_straight_for_fwsnrseg requires 0 or 3 arguments (audio, parameters, filename).')
end