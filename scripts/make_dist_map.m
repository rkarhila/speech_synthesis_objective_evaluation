function [ distmap , reff0,testf0 ]=make_dist_map(test_audio,ref_audio,ds_type)

local_conf


reff0=[];
testf0=[];

% Tidy wav files (remove silence from beginning and end)
% Let's kludge bluntly:

%    limits=find(test_audio>mean(abs(test_audio))/5);
%    test_audio=test_audio(limits(1):limits(length(limits)));

%    limits=find(ref_audio>mean(abs(ref_audio))/5);
%    ref_audio=ref_audio(limits(1):limits(length(limits)));

fs = 16000;
mel_dim = 21;

frame_ms = 25;

step_ms = 10 ; % 5 ms step
frame_rate = ceil(1000/step_ms);

% switch spec_method
%     case 'fft'
%         step_ms = 10 ; % 5 ms step
%         frame_rate = ceil(1000/step_ms);
%     case 'straight'
%         step_ms = 10 ; % 5 ms step
%         frame_rate = ceil(1000/step_ms);
% end

step_length=fs*step_ms/1000;
frame_length=fs*frame_ms/1000;

aux_noise=rand([frame_length,1])*exp(-60);

spectrum_dim=1024;
fft_dim=spectrum_dim/2+1;

% FWS:
M = melbankm(mel_dim, spectrum_dim, fs, 0, 0.5, 'u');
condition_num=1;
gamma1=0.2;


% MCEP-D
cep_dim=39;




len_test = size(test_audio,1);
len_ref = size(ref_audio,1);

fs_test=fs;
fs2_ref=fs;

sample_adj_step = fs*0.005;
sample_adj_max = 10*sample_adj_step;

nr_frames_test=floor((len_test-frame_length)/step_length);
nr_frames_ref=floor((len_ref-frame_length)/step_length);


% Get spectral features:



% reference for adjustment
ds1=50;

% Tricky bit: Make frame-by-frame distance map that is not symmetric, but
% satisfies the constraints of global distance maps, and the
% files are not of equal length...


%    for sample_adjustment = -1*sample_adj_max:sample_adj_step:sample_adj_max;

% Let's take each frame from audio1 and compare to all frames
% of audio2

distmap=zeros(nr_frames_test,nr_frames_ref);

% Let's get FFT:s for all samples:



win_step=step_ms*fs/1000;
hamwin=hamming(frame_ms*fs/1000);


switch ds_type
    
    case 'llr'
        
        N = 10;
        
        a_test=zeros(nr_frames_test,N+1);
        
        for i=1:nr_frames_test
            framestart=(i-1)*step_length+1;
            feas_test = hamwin.*test_audio(framestart:framestart+ ...
                frame_length-1);
            
            if (sum(abs(feas_test))) == 0
                feas_test=aux_noise;
            end
            
            [ay,ry] = ilpc(feas_test,N);
            a_test(i,:)=ay';
            
        end
        
        a_ref=zeros(nr_frames_ref,N+1);
        R_ref=zeros(N+1,N+1,nr_frames_ref);
        
        for i=1:nr_frames_ref
            
            framestart=(i-1)*step_length+1;
            feas_ref = hamwin.*ref_audio(framestart:framestart+frame_length-1);
            
            
            [ax,rx] = ilpc(feas_ref,N);
            a_ref(i,:) = ax;
            
            rx = rx/rx(1);
            R_ref(:,:,i) = toeplitz(rx);
            
        end
        
        
        for i=1:nr_frames_test
            for j=1:nr_frames_ref
                
                
                N = 10;
                
                %                [ax,rx] = ilpc(x,N);
                %                [ay,ry] = ilpc(y,N);
                
                %rx = rx/rx(1);
                %ry = ry/ry(1);
                
                %  R =toeplitz(rx);
                
                ay=a_test(i,:)';
                ax=a_ref(j,:)';
                
                R=R_ref(:,:,j);
                
                num = ay'*R*ay;
                den = ax'*R*ax;
                
                distmap(i,j) = log(num/den);
                
            end  
        end
            

    case 'straight-snr'
        
        %prm.F0frameUpdateInterval=10;     
        %prm.F0searchUpperBound=450;            
        %prm.F0searchLowerBound=40;             
        %prm.spectralUpdateInterval=10;    

        feas_test=zeros(nr_frames_test,mel_dim);
        % insert straight analysis here:
        [f0raw,ap,analysisParams]=exstraightsource(test_audio,fs,prm);
        [n3sgram,nalysisParamsSp]=exstraightspec(test_audio,f0raw,fs,prm);
        testf0=f0raw;

        for i=1:nr_frames_test
            feas = n3sgram(:,i);
            spec_norm = bsxfun(@times, feas, 1./sum(feas));
            mel_norm=M*spec_norm;
            feas_test(i,:)=mel_norm;
        end

        feas_ref=zeros(nr_frames_ref,mel_dim);

        [f0raw2,ap2,analysisParams]=exstraightsource(ref_audio,fs,prm);
        [n3sgram2,nalysisParamsSp]=exstraightspec(ref_audio,f0raw2,fs,prm);
        reff0=f0raw2;

        for i=1:nr_frames_ref
            feas = n3sgram2(:,i);
            spec_norm = bsxfun(@times, feas, 1./sum(feas));
            mel_norm=M*spec_norm;
            feas_ref(i,:)=mel_norm;
        end

        for i=1:nr_frames_test
            mel_norm_test=max(feas_test(i,:),exp(-700));
            for j=1:nr_frames_ref

                %sum(abs(feas_ref(j,:)-feas_test(i,:)))
                
                mel_norm_ref=max(feas_ref(j,:),exp(-700));

                W1 = power(mel_norm_ref,gamma1);
                S1 = 10*log10(power(mel_norm_ref,2)./power(mel_norm_ref-mel_norm_test,2)); % min: values below zero are unlikely, max: Inf
                S1 = max(min(S1,35),-10);
                cur_S1 = sum(sum(W1.*S1)./sum(W1));
                %cur_S2(windex)=-1*cur_S1;
                distmap(i,j)=cur_S1;        
                
            end


                %disp(sample_adjustment/sample_adj_step+1)

        end
        distmap=35-distmap;

                


    case 'fft-snr'

        feas_test=zeros(nr_frames_test,mel_dim);
        % insert straight analysis here:

        for i=1:nr_frames_test
            framestart=(i-1)*step_length+1;
            audio_short = hamwin.*test_audio(framestart:framestart+frame_length-1);
            feas =sqrt(abs(fft(audio_short,fft_dim)));


            spec_norm = bsxfun(@times, feas, 1./sum(feas));
            mel_norm=M*spec_norm;
            feas_test(i,:)=mel_norm;
        end

        feas_ref=zeros(nr_frames_ref,mel_dim);


        for i=1:nr_frames_ref
            framestart=(i-1)*step_length+1;
            audio_short = hamwin.*ref_audio(framestart:framestart+frame_length-1);
            feas =sqrt(abs(fft(audio_short,fft_dim)));

            spec_norm = bsxfun(@times, feas, 1./sum(feas));
            mel_norm=M*spec_norm;
            feas_ref(i,:)=mel_norm;
        end


        for i=1:nr_frames_test
            mel_norm_test=max(feas_test(i,:),exp(-700));
            for j=1:nr_frames_ref

                mel_norm_ref=max(feas_ref(j,:),exp(-700));

                W1 = power(mel_norm_ref,gamma1);
                S1 = 10*log10(power(mel_norm_ref,2)./power(mel_norm_ref-mel_norm_test,2)); % min: values below zero are unlikely, max: Inf
                S1 = max(min(S1,35),-10);
                cur_S1 = sum(sum(W1.*S1)./sum(W1));
                %cur_S2(windex)=-1*cur_S1;
                distmap(i,j)=cur_S1;

                %disp(sample_adjustment/sample_adj_step+1)
            end

        end
        distmap=35-distmap;

    case 'fft-mcd'

        feas_test=zeros(nr_frames_test,mel_dim);

        for i=1:nr_frames_test

            framestart=(i-1)*step_length+1;
            audio_short = hamwin.*test_audio(framestart:framestart+frame_length-1);

            feas =sqrt(abs(fft(audio_short,fft_dim)));
            feas_test(i,:)=dct(M*feas);
        end

        feas_ref=zeros(nr_frames_ref,mel_dim);

        for i=1:nr_frames_ref

            framestart=(i-1)*step_length+1;
            audio_short = hamwin.*ref_audio(framestart:framestart+frame_length-1);

            feas =sqrt(abs(fft(audio_short,fft_dim)));

            feas_ref(i,:)=dct(M*feas);


        end


        for i=1:nr_frames_test
            mcep_test=feas_test(i,:);
            for j=1:nr_frames_ref

                mcep_ref=feas_ref(j,:);

                distmap(i,j)=sqrt(2*sum(power(mcep_test(2:min(mel_dim,cep_dim+1))-mcep_ref(2:min(mel_dim,cep_dim+1)),2)));

            end

        end

        
    case 'straight-mcd'
        %prm.F0frameUpdateInterval=10;     
        %prm.F0searchUpperBound=450;            
        %prm.F0searchLowerBound=40;             
        %prm.spectralUpdateInterval=10;    

        feas_test=zeros(nr_frames_test,mel_dim);

        % insert straight analysis here:
        [f0raw,ap,analysisParams]=exstraightsource(test_audio,fs,prm);
        [n3sgram,nalysisParamsSp]=exstraightspec(test_audio,f0raw,fs,prm);
        testf0=f0raw;

         for i=1:nr_frames_test
              feas_test(i,:)=dct(M*n3sgram(:,i));
         end


        feas_ref=zeros(nr_frames_ref,mel_dim);
        [f0raw2,ap,analysisParams]=exstraightsource(ref_audio,fs,prm);
        [n3sgram2,nalysisParamsSp]=exstraightspec(ref_audio,f0raw2,fs,prm);
        reff0=f0raw2;
        
        for i=1:nr_frames_ref
            
            feas_ref(i,:)=dct(M*n3sgram2(:,i));

        end
        
        

        for i=1:nr_frames_test
            mcep_test=feas_test(i,:);

            for j=1:nr_frames_ref

               mcep_ref=feas_ref(j,:);

               distmap(i,j)=sqrt(2*sum(power(mcep_test(2:min(mel_dim,cep_dim+1))-mcep_ref(2:min(mel_dim,cep_dim+1)),2)));

            end

        end
        
    
        if sum(isnan(distmap(:)))>0
            disp('Trouble: Contains NaNs; Changing to zeros');
            distmap(isnan(distmap))=0;            
        end
        if min(distmap(:))<0
            disp('Trouble: Contains negative numbers; Adding minimum value to map');
            distmap=distmap+min(distmap(:))
        end
                        
end


