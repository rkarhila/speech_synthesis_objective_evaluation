function [ audio ] = remove_start_and_end_silence( audio , frame_length, step_length)
%Remove silent frames from start and end of audio clip
%   According to http://www.sciencedirect.com/science/article/pii/S0167639309001289

        local_conf

        audio=audio*(1/max(audio));
        len_audio = size(audio,1);
        nr_frames_train=floor((len_audio-frame_length)/step_length);

        % VAD

        audio_short = zeros(1,nr_frames_train);

        for j=1:nr_frames_train
            framestart=(j-1)*step_length+1;
            audio_short(j) = 20*log10(std(hamming(frame_length).*audio(framestart:framestart+frame_length-1))+eps);
        end

        limits=find((audio_short>max(audio_short)-30) & audio_short>-55);
        
        
        fullsentstart=limits(1)*step_length;
        fullsentend=limits(length(limits))*step_length;

        audio=audio(fullsentstart:fullsentend);
end

