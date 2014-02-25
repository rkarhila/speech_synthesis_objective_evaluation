function test_data = calculate_feas(test_filelist, spec_method, test_feature_domain, use_vad)

%Feature extraction
%
% spec_method options straight, fft
% test_feature_domain options log-mel, mel-cep

fs = 16000;
mel_dim = 21;
spectrum_dim=1024;

M = melbankm(mel_dim, spectrum_dim, fs, 0, 0.5, 'u');

cep_dim = 13;

frame_ms = 25;
step_ms = 10 ; % 5 ms step

step_length=fs*step_ms/1000;
frame_length=fs*frame_ms/1000;

hamwin=hamming(frame_ms*fs/1000);

% FFT

spectrum_dim=1024;
fft_dim=spectrum_dim/2+1;

% STRAIGHT

prm.F0frameUpdateInterval=10;     
prm.F0searchUpperBound=450;            
prm.F0searchLowerBound=40;             
prm.spectralUpdateInterval=10;  

for findex=1:length(test_filelist)

    [ test_audio , fs2, bits2 ] = wavread(test_filelist{findex});
    
    if ne(fs2, fs)
        test_audio=resample(test_audio, fs, fs1);
    end
    
    
    % normalise audio

    test_audio=test_audio*(1/max(test_audio));

    len_test = size(test_audio,1);
    nr_frames_test=floor((len_test-frame_length)/step_length);
     
    % VAD

    if use_vad
    
    audio_short = zeros(1,nr_frames_test);

    for frame_index=1:nr_frames_test
        framestart=(frame_index-1)*step_length+1;
        audio_short(frame_index) = 20*log10(std(hamwin.*test_audio(framestart:framestart+frame_length-1))+eps);
    end

    vad_mask=(audio_short>max(audio_short)-30) & audio_short>-55;
    
    else
        
    vad_mask=ones(nr_frames_test,1);
    
    end

    % FEATURE EXTRACTION
 
    switch spec_method

        case 'straight'  

        [f0raw,ap,analysisParams]=exstraightsource(test_audio,fs,prm);
        [spec_feas,analysisParamsSp]=exstraightspec(test_audio,f0raw,fs,prm);

        case 'fft'

        for frame_index=1:nr_frames_test
            framestart=(frame_index-1)*step_length+1;
            audio_short = hamwin.*test_audio(framestart:framestart+frame_length-1);
            spec_feas(:,frame_index) = sqrt(abs(fft(audio_short,fft_dim)));
        end

    end % spec method
        
    feas_test=zeros(nr_frames_test,mel_dim);
    
    switch test_feature_domain
        
        case 'log-mel'
            
        for frame_index=1:nr_frames_test
            feas_test(frame_index,:)=log(M*spec_feas(:,frame_index)); 
        end
        
        case 'mel-cep'
            
        for frame_index=1:nr_frames_test
            feas_test(frame_index,:)=dct(log(M*spec_feas(:,frame_index)));
        end
        
        feas_test = feas_test(:,2:cep_dim);
        
    end
        
        test_data{findex}=feas_test(find(vad_mask==1),:);
end