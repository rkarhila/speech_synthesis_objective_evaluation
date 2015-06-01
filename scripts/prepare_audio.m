% PREPARE_AUDIO  Load and normalise audio and apply VAD
%
% Returns a structure with fields:
%   audio           The normalised waveform
%   framecount      Number of frames
%   vadlimits       First and last speech frames in audio
%   speech_frames   Mask for speech frames
%   nr_frames_test  A count of speech frames
%   
%
function [audiostruct] = prepare_audio(varargin)


%
%  Too many things happen here and this is in need of cleaning!
%


audiofile=varargin{1};
params=varargin{2};
filename=varargin{3};

% Check the existence of the file, since audioread is not smart enough to
% give a readable error:

if ~exist(audiofile,'file')
   error(['prepare_audio: ',audiofile, ' does not exist.'])
end

% Load audio & resample if necessary
[ audio , fs1 ] = audioread(audiofile);

if ne(fs1, params.fs)
    audio=resample(audio, params.fs, fs1);
end

%
% Normalise to 0.0...1.0:
%
audio=audio*(1/max(audio));



% Calculate frame size
step_length=params.fs*params.step_ms/1000;
frame_length=params.fs*params.frame_ms/1000;



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
speech_frames=find(vadmask==1);



endframe=max(speech_frames);%-ceil(frame_length/step_length ));
startframe=speech_frames(1);

vadlimits= [ (startframe-1)*step_length+1, (endframe+1)*step_length ];

%
% Clip start and end silences from audio (no need to extract 
% thos features):
%
audio=audio(vadlimits(1):vadlimits(2));


%
% After clipping, fix the speech frame list:
%

len_test=size(audio,1);
nr_frames_test=floor((len_test-frame_length)/step_length)+1;

speech_frames=speech_frames-(startframe-1);





%
% If audio is completely silent, add small jitter:
%
if (min(abs(audio))==0)
  aux_noise=rand([length(audio),1])*exp(-16);
  aux_noise(audio > 0 | audio < 0)=0;
  audio = audio+aux_noise;
end


%
% Compute number of frames for whatever reason:
%
% (What happens? Why is it done like this?)
framecount=floor(((vadlimits(2)-vadlimits(1))-frame_length)/step_length);




% Late additions: Let's return a struct instead of massive amount of
% variables.
%

%nr_test_frames=max(speech_frames);

audiostruct.audio = audio;
audiostruct.framecount = framecount;
audiostruct.vadlimits = vadlimits;
audiostruct.speech_frames = speech_frames;
audiostruct.nr_frames_test = nr_frames_test;
