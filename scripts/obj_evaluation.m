function [ averagedist, distlist, runtime ]=obj_evaluation(filepath, reference_sent_list, ...
    test_sent_list)

local_conf
mapdirectory=LOCAL_MAPDIR;

monitoring=0;
figuring=0;

spec_method='straight'; % fft or straight
distance_measure = 'fwsnrseg'; % fwsnrseg or mcd or llr

% So, we have list of reference files and a list of test files.
% Let's assume that they all exist and behave well



reffilelist = textread(reference_sent_list,'%s' );
testfilelist = textread(test_sent_list,'%s' );


mapmethods={'fft-snr','straight-snr','fft-mcd', 'straight-mcd','llr'};
mapmethods={'straight-snr','fft-mcd', 'straight-mcd','llr'};
mapf0measures={'rmsd','voicingdiff'}

globalf0measures={'rmse','diffvar'}

testcount=length(mapmethods)*...
    (length(mapmethods)+length(mapf0measures))+length(globalf0measures)

distlist=zeros(length(testfilelist),testcount);

if ne(length(testfilelist), length(testfilelist))
    disp(['Filelists are different size, this won`t end well']);
    
end

n=length(testfilelist);
Length=n;
Count=0;

if monitoring==1;
    WaitBar = waitbar(0,'Initializing waitbar...');
else
    WaitBar = NaN;
end

tic

% Loop over file pairs:

for i=1:length(testfilelist)
    
    
    fs = 16000;
    
    step_matrix=[1 1 1;1 0 1;0 1 1;1 2 2;2 1 2];
    %step_matrix=[1 1 1.0;0 1 1.0;1 0 1.0];
    
    [ ref_audio , fs1, bits1 ] = wavread([filepath,reffilelist{i}]);
    [ test_audio , fs2, bits2 ] = wavread([filepath,testfilelist{i}]);
    
    if ne(fs1, fs2)
        disp(['Different sampling frequency, this won`t end ' ...
            'well']);
        
    end
    if ne(fs1, fs)
        ref_audio=resample(ref_audio, fs, fs1);
    end
    if ne(fs2, fs)
        test_audio=resample(test_audio, fs, fs1);
    end
    
    if ne(bits1,bits2)
        disp(['Different nr of bits. Doesn`t happen too often, but ' ...
            'is it dangerous?']);
    end
    
    
    ref_audio=ref_audio*(1/max(ref_audio));
    test_audio=test_audio*(1/max(test_audio));
    
    
    
    [testpath,testfilename,testfilext]=fileparts(testfilelist{i});
    speakercode=regexprep( regexprep(testpath,'.*blizzard_wavs_and_scores[a-z0-9_-]+',''), '[^a-zA-Z0-9-_]', '_');
    disp(testfilename);
    
    
    if (figuring == i)
        figure(1)
    end
    
    distmaps={};
    
    
    testf0name=[mapdirectory,speakercode,testfilename,'_testf0.map'];
    reff0name=[mapdirectory,speakercode,testfilename,'_reff0.map'];
    
    for y=1:length(mapmethods)
        mapmethod=mapmethods{y};
        mapname=[mapdirectory,speakercode,testfilename,'_',mapmethod,'_norm.map'];
        
        if exist(mapname, 'file')
            distmaps{y}=load(mapname, '-ascii');
        else
            [distmap,reff0,testf0]=make_dist_map(test_audio, ref_audio, ...
                spec_method, mapmethod);
            %distmap=(distmap-min(distmap(:)))/(max(distmap(:)-min(distmap(:))));
            distmaps{y}=distmap;
            save(mapname, 'distmap', '-ascii');
            if (length(reff0))>0
                save(reff0name, 'reff0', '-ascii');
                save(testf0name, 'testf0', '-ascii');
            end
        end
    end

    %maps{i}=distmaps

    reff0=load(reff0name, '-ascii');
    testf0=load(testf0name, '-ascii');

    
    result=zeros(1,testcount);

    
    meanf0diff=abs(mean(testf0(testf0>0)) - mean(reff0(reff0>0)));
    stdf0diff=abs(std(testf0(testf0>0)) - std(reff0(reff0>0)) );
    
    
    result(testcount-1)=meanf0diff;
    result(testcount)=stdf0diff;

    %methodpaths={};

    
    for z=1:length(mapmethods)
        mapmethod=mapmethods{z};
        
       [pathp,pathq,min_cost_matrix,cost_on_best_path] = ...
            dpfast(distmaps{z},step_matrix,1);      
        
            
            
        % test_audio
        % Frame length=80 samples
        fs=16000;
        step_ms=10;
        step_length=fs*step_ms/1000;


        limits=find(ref_audio>mean(abs(ref_audio))/5);
        %test_audio=test_audio(limits(1):limits(length(limits)));

        %disp([limits(1), limits(length(limits))]);

        fullsentstart=floor(limits(1)/step_length);
        fullsentend=ceil(limits(length(limits))/step_length);

        fullsentpathp=pathp(pathp>fullsentstart & pathq < fullsentend);
        fullsentpathq=pathq(pathp>fullsentstart & pathq < fullsentend);

        %disp([length(fullsentpathp),length(fullsentpathq)])

        for y=1:length(mapmethods)
            %pathmethod=mapmethods{y};

            
            thiscost3=0;
            for j=1:length(fullsentpathp)
                thiscost3=thiscost3+distmaps{y}(fullsentpathp(j),fullsentpathq(j));
            end
            thiscost3 = thiscost3/length(fullsentpathp);
            

            result( (z-1)*(length(mapmethods)+length(mapf0measures)) + y) = thiscost3;
            
%            result((z-1)*length(mapmethods)^3+y*length(mapmethods))=thiscost3;
            
        end

        thiscost3=0;
        framecounter=0;
        voicingdiffcount=0;
        for j=1:length(fullsentpathp)
            % For debugging, obviously:
            %fprintf('%0.1f\t%0.1f\t%0.1f\n', [testf0(fullsentpathp(j)),reff0(fullsentpathq(j)), min(1, min(testf0(fullsentpathp(j)), reff0(fullsentpathq(j)))) * (testf0(fullsentpathp(j)) - reff0(fullsentpathq(j)))^2] );

            if testf0(fullsentpathp(j))> 0 && reff0(fullsentpathq(j)) > 0
                thiscost3=thiscost3+( testf0(fullsentpathp(j)) - reff0(fullsentpathq(j)) )^2;
                framecounter = framecounter + 1;
            elseif max(testf0(fullsentpathp(j)), reff0(fullsentpathq(j))) > 0
                voicingdiffcount=voicingdiffcount+1;
            end
        end
        thiscost3 = sqrt(thiscost3/framecounter);
        
        result( (z-1)*(length(mapmethods)+length(mapf0measures)) + length(mapmethods) + 1 ) = thiscost3;
        
        result( (z-1)*(length(mapmethods)+length(mapf0measures)) + length(mapmethods) + 2 ) = voicingdiffcount/length(fullsentpathp);

        
        
        %            distlist(i,k1:k2)=[thiscost,length(twosecpathp)- ...
        %                   testlength]
        
    end
    
%        disp(result);
        fprintf('%0.1f\t', result);
        disp('\n');
        distlist(i,:) = distlist(i,:) + result;

    
    
%    disp(testfilelist{i})
%    disp(distlist(i,:))
    
    if monitoring==1;
        
        %Here's the progress bar code
        t=toc;
        Perc=i/n;
        Trem=t/Perc-t; %Calculate the time remaining
        Hrs=floor(Trem/3600);Min=floor((Trem-Hrs*3600)/60);
        waitbar(Perc,WaitBar,[sprintf('%0.1f',Perc*100) '%, '...
            sprintf('%03.0f',Hrs) ':'...
            sprintf('%02.0f',Min) ':'...
            sprintf('%02.0f',rem(Trem,60)) ' remaining']);
        
    end
    
end

if monitoring==1;
    close(WaitBar);
end

averagedist=mean(abs(distlist));

runtime=toc;


    
    
    
    