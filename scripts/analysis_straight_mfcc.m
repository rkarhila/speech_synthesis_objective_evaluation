% ANALYSIS_STRAIGHT_MFCC
%
% Provides STRAIGHT-based MFCC features for computing MCD distance measure 
% in building a distance map.
%
function [returnable] = analysis_straight_mfcc(varargin)
%
if nargin == 0
    returnable = 'straight_for_fwsnr';

elseif nargin == 3

    local_conf

    audio_struct= varargin{1};
    
    test_audio = audio_struct.audio;
    nr_frames_test=audio_struct.nr_frames_test;
    speech_frames=audio_struct.speech_frames;
    
    params = varargin{2};
    
    filename = varargin{3}; % Not used for anything, as it is not judged 
                            % worthy to cache fft results
    itsok=0;

    if (CACHE_STRAIGHT == 1)
        % STRAIGHT extraction takes some time, so let's cache the
        % feature files
        stfilename=[LOCAL_FEATDIR,filename,'.params_', params.name];

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
    % 2. Mel-bank the spec and do discrete cosine transform on the banks:
    %
    
    M = melbankm(params.mel_dim, params.spectrum_dim, params.fs, 0, 0.5, 'u');
    
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
        returnable = struct('features',[feas_test, deltas(feas_test,3), deltas(deltas(feas_test,3))],'speech_frames',speech_frames(3:(length(speech_frames)-2))-2 );
    else
        speech_frames=speech_frames(speech_frames <= length(feas_test));
        returnable = struct('features',feas_test,'speech_frames',speech_frames);
    end

else
    error('analysis_straight_for_fwsnrseg requires 0 or 3 arguments (audio, parameters, filename).')
end