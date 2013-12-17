%
% Evaluate our development set 2009 EH2 
%

local_config

[ sim_averagedist, sim_distlist, sim_runtime ] = obj_evaluation('devel/sim_to_be_reference.3.scp','devel/sim_to_be_evaluated.3.scp');

[ nat_averagedist, nat_distlist, nat_runtime ] = obj_evaluation('devel/nat_to_be_reference.3.scp','devel/nat_to_be_evaluated.3.scp');


