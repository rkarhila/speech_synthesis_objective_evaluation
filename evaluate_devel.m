%
% Evaluate our development set 2009 EH2 
%

local_conf


if (matlabpool('size') == 0)
    matlabpool
end

if exist('devel/2009_EH2_objective_results_sim', 'file') == 0;
    [ sim_averagedist, b2009_EH2_sim_distlist, sim_runtime ] = obj_evaluation(BLIZZARD2009_RESULTDIR, 'devel/2009_EH2_sim.ref.scp','devel/2009_EH2_sim.test.scp');
    save('devel/2009_EH2_objective_results_sim','b2009_EH2_sim_distlist','-ascii');
end

if exist('devel/2009_EH2_objective_results_nat', 'file') == 0;
    [ nat_averagedist, b2009_EH2_nat_distlist, natruntime ] = obj_evaluation(BLIZZARD2009_RESULTDIR, 'devel/2009_EH2_nat.ref.scp','devel/2009_EH2_nat.test.scp');
    save('devel/2009_EH2_objective_results_nat','b2009_EH2_nat_distlist','-ascii');
end

evaluate_wilcoxon()