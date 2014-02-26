function [audio,framecount,vadlimits] = prepare_audio(audiofile, varargin)
% PREPARE_AUDIO  Load and normalise audio and apply VAD
%   [B,FRAMECOUNT,VADLIMITS] = PREPARE_AUDIO(A) loads wav file, normalises 
%               and applies voice activity detection based on signal power
%   [B,FRAMECOUNT,VADLIMITS] = PREPARE_AUDIO(A,[START END]) loads the file,
%               normalises and crops the audio based on the extra 
%               start/end cutoff parameters.


% Load local variables
local_conf


% Load audio & resample if necessary
[ audio , fs1 ] = audioread(audiofile);

if ne(fs1, fs)
    audio=resample(audio, fs, fs1);
end

audio=audio*(1/max(audio));


% Check if we have audio cropping given as parameter of if we have to
% calculate is ourselves.
if (length(varargin)==1)

    vadlimits=length(varargin);        
   
else

    % Calculate frame size
    step_length=fs*step_ms/1000;
    frame_length=fs*frame_ms/1000;
    
    % Voice Activity Detection from 
    % http://www.sciencedirect.com/science/article/pii/S0167639309001289    

    len_test = size(audio,1);
    nr_frames_test=floor((len_test-frame_length)/step_length);

    % VAD

    audio_short = zeros(1,nr_frames_test);
    hamwin=hamming(frame_length);
    for i=1:nr_frames_test
        framestart=(i-1)*step_length+1;
        audio_short(i) = 20*log10(std(hamwin.*audio(framestart:framestart+frame_length-1))+eps);
    end

    vadmask=(audio_short>max(audio_short)-30) & audio_short>-55;

    startframe=find(vadmask==1);

    endframe=startframe(length(startframe));
    startframe=startframe(1);

    vadlimits= [ (startframe-1)*step_length+1, endframe*step_length ];
end

audio=audio(vadlimits(1):vadlimits(2));
framecount=floor(((vadlimits(2)-vadlimits(1))-frame_length)/step_length);

