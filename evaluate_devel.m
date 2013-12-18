%
% Evaluate our development set 2009 EH2 
%

local_conf

if exist('devel/objective_results_sim', 'file') == 0;
    [ sim_averagedist, sim_distlist, sim_runtime ] = obj_evaluation(BLIZZARD2009_RESULTDIR, 'devel/sim_to_be_reference.3.scp','devel/sim_to_be_evaluated.3.scp');
    save('devel/objective_results_sim','sim_distlist','-ascii');
end

if exist('devel/objective_results_nat', 'file') == 0;
    [ nat_averagedist, nat_distlist, nat_runtime ] = obj_evaluation(BLIZZARD2009_RESULTDIR, 'devel/nat_to_be_reference.3.scp','devel/nat_to_be_evaluated.3.scp');
    save('devel/objective_results_nat','nat_distlist','-ascii');
end

evaluate_wilcinson