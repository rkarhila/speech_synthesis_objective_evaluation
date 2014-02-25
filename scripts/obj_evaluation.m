function [ distlist, runtime ]=obj_evaluation(filepath, reference_sent_list, ...
    test_sent_list, mapmethods)

local_conf
mapdirectory=LOCAL_MAPDIR;

monitoring=0;
figuring=0;

%spec_method='straight'; % fft or straight
%distance_measure = 'fwsnrseg'; % fwsnrseg or mcd or llr

% So, we have list of reference files and a list of test files.
% Let's assume that they all exist and behave well



reffilelist = textread(reference_sent_list,'%s' );
testfilelist = textread(test_sent_list,'%s' );


%mapmethods={'fft-snr','straight-snr','fft-mcd', 'straight-mcd','llr'};

mapf0measures={};
globalf0measures={};
%mapf0measures={'rmsd','voicingdiff'};
%globalf0measures={'rmse','diffvar'};


testcount=length(mapmethods)*...
    (length(mapmethods)+length(mapf0measures))+length(globalf0measures);

distlist=zeros(length(testfilelist),testcount);

if ne(length(testfilelist), length(testfilelist))
    disp('Filelists are different size, this won`t end well');
    
end

n=length(testfilelist);

if monitoring==1;
    WaitBar = waitbar(0,'Initializing waitbar...');
else
    WaitBar = NaN;
end

tic

% Loop over file pairs:


parfor i=1:length(testfilelist)
    
    [testpath,testfilename,testfilext]=fileparts(testfilelist{i});
    speakercode=regexprep( testpath, '[^a-zA-Z0-9-_]', '_');
    disp(testfilename);
    
    distmaps=cell(length(mapmethods));
    
    %testf0name=[mapdirectory,speakercode,testfilename,'_testf0.map'];
    %reff0name=[mapdirectory,speakercode,testfilename,'_reff0.map'];
    
    for y=1:length(mapmethods)
        spec_and_distmethod=mapmethods{y};
        specmethod=spec_and_distmethod{1};
        distmethod=spec_and_distmethod{2};
        mapmethod=[specmethod,'_',distmethod];
        
        mapname=[mapdirectory,speakercode,testfilename,'_',mapmethod,'_norm.map'];
        
        if exist(mapname, 'file')
            distmaps{y}=load(mapname, '-ascii');
        else
            usevad=1;
            ref_feat=calculate_feas([filepath,reffilelist{i}], specmethod, distmethod,usevad);
            test_feat=calculate_feas([filepath,testfilelist{i}], specmethod,distmethod,usevad);
            
            [distmap]=make_dist_map(test_feat,ref_feat, ...
                distmethod);
            
            %distmap=(distmap-min(distmap(:)))/(max(distmap(:)-min(distmap(:))));
            
            distmaps{y}=distmap;
            parsave(mapname, distmap);
        end
    end

    result=zeros(1,testcount);    

    step_matrix=[1 1 1/sqrt(2);1 0 1;0 1 1;1 2 sqrt(2);2 1 sqrt(2);1 3 2; 3 1 2];
    %step_matrix=[1 1 1.0;0 1 1.0;1 0 1.0];

    
    for z=1:length(mapmethods)
        %mapmethod=mapmethods{z};
        
       [pathp,pathq,min_cost_matrix,cost_on_best_path] = ...
            dpfast(distmaps{z},step_matrix,1);      
        
            
            
        % test_audio
        % Frame length=80 samples
        fs=16000;
        step_ms=10;
        step_length=fs*step_ms/1000;


        %test_audio=test_audio(limits(1):limits(length(limits)));

        %disp([limits(1), limits(length(limits))]);

        fullsentpathp=pathp;
        fullsentpathq=pathq;

        %disp([length(fullsentpathp),length(fullsentpathq)])

        for y=1:length(mapmethods)
            %pathmethod=mapmethods{y};

            
            thiscost3=0;

%           Again, which way should it go?
%            for j=1:length(fullsentpathp)
%                thiscost3=thiscost3+distmaps{y}(fullsentpathp(j),fullsentpathq(j));
%            end

            for j=1:length(fullsentpathp)
                thiscost3=thiscost3+distmaps{y}(fullsentpathp(j),fullsentpathq(j));
            end

            thiscost3 = thiscost3/length(fullsentpathp);
            

            result( (z-1)*(length(mapmethods)+length(mapf0measures)) + y) = thiscost3;
            
%            result((z-1)*length(mapmethods)^3+y*length(mapmethods))=thiscost3;
            
        end
       
        
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


    
    
    
    