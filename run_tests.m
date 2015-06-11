local_conf;

% Figurecounter
fc=100;


% First, let's make sure that we have all the tests run and results loaded:

if ~exist('tests','var')
    tests=cell(6,1);

    evaluate_test_2008;
    tests{1}=tests2008;

    evaluate_test_2009;
    tests{2}=tests2009;

    evaluate_test_2010;
    tests{3}=tests2010;

    evaluate_test_2011;
    tests{4}=tests2011;

    evaluate_test_2012;
    tests{5}=tests2012;

    evaluate_test_2013;
    tests{6}=tests2013;
end


disp('All the tests have been run (or results loaded).')
disp('Continuing with collect_results_and_analyse_and_draw_plots.m');


collect_results_and_analyse_and_draw_plots