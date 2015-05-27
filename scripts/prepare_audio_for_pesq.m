% PREPARE_AUDIO_FOR_PESQ  Load audio, plain and simple.
%
% Returns a structure with fields:
%   audio           The waveform
%   
% (A structure is only returned to maintain some similarity between
%  preprocesing functions.)
function [audiostruct] = prepare_audio_for_pesq(varargin)


%
%  Too many things happen here and this is in need of cleaning!
%


audiofile=varargin{1};
params=varargin{2};

% Load audio & resample if necessary
[ audio , fs1 ] = audioread(audiofile);

if ne(fs1, params.fs)
    audio=resample(audio, params.fs, fs1);
end

%
% Normalise to 0.0...1.0:
%
%audio=audio*(1/max(audio));

audiostruct.audio = audio;
