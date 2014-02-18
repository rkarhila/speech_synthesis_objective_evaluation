function feas_test = calculate_feas(testfile, analysismethod, distmethod, usevad)
%
% spec_method options straight, fft
% test_feature_domain options log-mel, mel-cep 

local_conf




[audiofilepath,audiofilename,audiofilext]=fileparts(testfile);
speakercode=regexprep( audiofilepath, '[^a-zA-Z0-9-_]', '_');
%disp(testfilename);

itsok=0;


if (CACHE_FEATURES == 1)
    cachefilename=[LOCAL_FEATDIR,speakercode,'_',audiofilename,'.',analysismethod,'_',distmethod];
    if exist(cachefilename, 'file')
        feas_test = load(cachefilename, '-ascii');
        itsok=1;
    end
end

if itsok~=1

    fs = 16000;
    mel_dim = 21;
    spectrum_dim=1024;

    M = melbankm(mel_dim, spectrum_dim, fs, 0, 0.5, 'u');

    cep_dim = 13;

    frame_ms = 25;
    step_ms = 10 ; % 5 ms step

    step_length=fs*step_ms/1000;
    frame_length=fs*frame_ms/1000;



    % FFT

    fft_dim=spectrum_dim/2+1;
    hamwin=hamming(frame_ms*fs/1000);



    % FEATURE EXTRACTION

    [test_audio,nr_frames_test]=prepare_audio(testfile,'use_vad',usevad);
    
    switch analysismethod
        case 'straight' 

            if (CACHE_STRAIGHT == 1)
                % STRAIGHT extraction takes some time, so let's cache the
                % feature files
                stfilename=[LOCAL_FEATDIR,speakercode,'_',audiofilename,'.straight-spec'];

                if exist(stfilename, 'file')
                    feas_test = load(stfilename, '-ascii');
                else
                    [f0raw,~,analysisParams]=exstraightsource(test_audio,fs,prm);
                    [feas_test,analysisParamsSp]=exstraightspec(test_audio,f0raw,fs,prm);
                    parsave(stfilename, feas_test);
                end

            else

                [f0raw,~,analysisParams]=exstraightsource(test_audio,fs,prm);
                [feas_test,analysisParamsSp]=exstraightspec(test_audio,f0raw,fs,prm);

            end
        case 'fft'

            if (CACHE_FEATURES == 2)

                stfilename=[LOCAL_FEATDIR,speakercode,'_',audiofilename,'.fft-spec'];

                if exist(stfilename, 'file')
                    feas_test = load(stfilename, '-ascii');
                else

                    feas_test=zeros(nr_frames_test,fft_dim);
                    for frame_index=1:nr_frames_test
                        framestart=(frame_index-1)*step_length+1;
                        audio_short = hamwin.*test_audio(framestart:framestart+frame_length-1);
                        feas_test(frame_index,:) = sqrt(abs(fft(audio_short,fft_dim)));
                    end
                    feas_test=feas_test';
                    parsave(stfilename, feas_test);
                end
            else

                feas_test=zeros(nr_frames_test,fft_dim);
                for frame_index=1:nr_frames_test
                    framestart=(frame_index-1)*step_length+1;
                    audio_short = hamwin.*test_audio(framestart:framestart+frame_length-1);
                    feas_test(frame_index,:) = sqrt(abs(fft(audio_short,fft_dim)));
                end
                feas_test=feas_test';

            end


        case 'llr' % Nothing to cache really.         
            hamwin=hamming(frame_ms*fs/1000);
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
            feas_test=feas_test;
                
    end
    
    switch distmethod
        
        case 'snr'
            spec_feas=feas_test;
            feas_test=zeros(nr_frames_test,mel_dim);

            for i=1:nr_frames_test
                feas = spec_feas(:,i);
                spec_norm = bsxfun(@times, feas, 1./sum(feas));              
                mel_norm=M*spec_norm;
                feas_test(i,:)=mel_norm;
            end
        case 'log-mel' 

            spec_feas=feas_test;
            feas_test=zeros(nr_frames_test,mel_dim);
            for frame_index=1:nr_frames_test
                feas_test(frame_index,:)=log(M*spec_feas(:,frame_index)); 
            end
            
            if (CACHE_FEATURES == 1)
                cachefilename=[LOCAL_FEATDIR,speakercode,'_',audiofilename,'.',analysismethod,'_',distmethod];
                parsave(cachefilename, feas_test);
            end    
            
        case 'mcd'

            spec_feas=feas_test;
            feas_test=zeros(nr_frames_test,mel_dim);
            for frame_index=1:nr_frames_test
                feas_test(frame_index,:)=dct(log(M*spec_feas(:,frame_index)));
            end

            feas_test = feas_test;%(:,2:cep_dim)';

            if (CACHE_FEATURES == 1)
                cachefilename=[LOCAL_FEATDIR,speakercode,'_',audiofilename,'.',analysismethod,'_',distmethod];
                parsave(cachefilename, feas_test);
            end    

            
            
        case 'llr'

            dummy=1;

    end

end

