function [test_results, runtime] = evaluate_with_pesq(filepath, reference_sent_list, test_sent_list )


local_conf

% So, we have list of reference files and a list of test files.
% Let's assume that they all exist and behave well

reffilelist = textread(reference_sent_list,'%s' );
testfilelist = textread(test_sent_list,'%s' );

if ne(length(testfilelist), length(testfilelist))
    disp('Filelists are different size, this won`t end well');
end


tic

%
% Initialise the result array for PESQ:
%
pesq_results_all=zeros(length(testfilelist),length(pesq_tests));


parfor i=1:length(testfilelist)    
    
    pesqref=pesq_tests{1}.preprocessing.function([filepath,reffilelist{i}], pesq_tests{1}.preprocessing);
    pesqtest=pesq_tests{1}.preprocessing.function([filepath,testfilelist{i}],pesq_tests{1}.preprocessing);

    scores_nb = pesqbin( pesqref.audio, pesqtest.audio, 16000, 'nb' );
    scores_wb = pesqbin( pesqref.audio, pesqtest.audio, 16000, 'wb' );

    pesq_results_all(i,:) =  pesq_results_all(i,:) + [  5 - scores_nb(1), 5 - scores_nb(2), 5 - scores_wb  ];

    disp(pesq_results_all(i,:));
end

test_results=pesq_results_all;

runtime=toc;