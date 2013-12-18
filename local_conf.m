

EVALHOME='/data/users/rkarhila/speech_synthesis_objective_evaluation'

addpath ([ EVALHOME, '/scripts'])
addpath ([ EVALHOME, '/include/columbia_ee_dtw'])
addpath ([ EVALHOME, '/include/voicebox'])
addpath ([ EVALHOME, '/include/colea'])
addpath /akulabra/projects/T40511/Modules/opt/STRAIGHT/V40_003



USE_STRAIGHT        = 1;

if USE_STRAIGHT == 1
    prm.F0frameUpdateInterval  = 10;     
    prm.F0searchUpperBound     = 450;            
    prm.F0searchLowerBound     = 40;             
    prm.spectralUpdateInterval = 10;      
end


%Save copies of distance maps for DTW testing
CACHE_DISTMAPS = 1;
LOCAL_MAPDIR   ='/akulabra/projects/T40511/synthesis/blizzard_eval/distmaps2/';


% This is not used for anything yet:
CACHE_FEATURES = 1;
LOCAL_FEATDIRY ='/akulabra/projects/T40511/synthesis/blizzard_eval/features/';


% This is not used for anything yet:
BLIZZARD2009_RESULTDIR = '/data/users/rkarhila/blizzard_results/blizzard_wavs_and_scores_2009_release_version_1/'

