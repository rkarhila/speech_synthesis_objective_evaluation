

EVALHOME='/work/asr/u/rkarhila/speech_synthesis_objective_evaluation/';

addpath ([ EVALHOME, '/scripts'])
addpath ([ EVALHOME, '/include/columbia_ee_dtw'])
addpath ([ EVALHOME, '/include/voicebox'])
addpath ([ EVALHOME, '/include/colea'])
addpath ([ EVALHOME, '/include/audioread'])
addpath ([ EVALHOME, '/include/gmmbayestb-v1.0'])
addpath ([ EVALHOME, '/include/matlab-pesq-wrapper'])
addpath ([ EVALHOME, '/include/applyhatch'])
addpath ([ EVALHOME, '/include/fitit'])
addpath ([ EVALHOME, '/include/logistic'])


addpath /work/asr/Modules/opt/STRAIGHT/V40_003

setenv('PATH', '/akulabra/projects/T40511/Modules/opt/pesq/amd_2/bin/:/akulabra/projects/T40511/Modules/opt/sptk/3.5/bin:/akulabra/projects/T40511/Modules/opt/hts/2.3alpha/bin:/home/rkarhila/bin:/usr/lib/lightdm/lightdm:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/opt/bin:/p/bin:/home/rkarhila/bin')

USE_STRAIGHT        = 1;

if USE_STRAIGHT == 1
    prm.F0frameUpdateInterval  = 10;     
    prm.F0searchUpperBound     = 450;            
    prm.F0searchLowerBound     = 40;             
    prm.spectralUpdateInterval = 10;      
end

CACHE_FEATURES = 1;
CACHE_STRAIGHT = 1;
LOCAL_FEATDIR ='/data/scratch/rkarhila/blizzard_eval_scratch/feat/';


%Save copies of distance maps for DTW testing
CACHE_DISTMAPS = 1;
LOCAL_MAPDIR   ='/data/scratch/rkarhila/blizzard_eval_scratch/distmaps/';


LOCAL_MIXTUREMODELDIR   ='/data/scratch/rkarhila/blizzard_eval_scratch/gmms/';




BLIZZARD2008_RESULTDIR = '/work/asr/u/rkarhila/blizzard_results/blizzard_wavs_and_scores_2008_release_version_1/';
BLIZZARD2009_RESULTDIR = '/work/asr/u/rkarhila/blizzard_results/blizzard_wavs_and_scores_2009_release_version_1/';
BLIZZARD2010_RESULTDIR = '/work/asr/u/rkarhila/blizzard_results/blizzard_wavs_and_scores_2010_release_version_1/';
BLIZZARD2011_RESULTDIR = '/work/asr/u/rkarhila/blizzard_results/blizzard_wavs_and_scores_2011_release_version_1/';
BLIZZARD2012_RESULTDIR = '/work/asr/u/rkarhila/blizzard_results/blizzard_wavs_and_scores_2012/afs/.inf.ed.ac.uk/group/blizzard/blizzard_2012/analysis/distribution/full_distribution/';
BLIZZARD2013_RESULTDIR = '/work/asr/u/rkarhila/blizzard_results/blizzard_wavs_and_scores_2013_release_version_1/';
%BLIZZARD2009_RESULTDIR = '/akulabra/projects/T40511/synthesis/blizzard_results/blizzard_wavs_and_scores_2009_release_version_1/'


fs = 16000;
mel_dim = 21;
frame_ms = 25;


step_ms = 10 ; % Used to be 5 ms step
frame_rate = ceil(1000/step_ms);

mapmethods={ {'fft','snr'},...
             {'straight','snr'},...
             {'fft','mcd'}, ...
             {'straight','mcd'}, ...
             {'llr','llr'}};

gaussmethods= { { 'straight', 'log-mel' }, ...
                { 'fft', 'log-mel'}, ...
                { 'straight', 'mcd' }, ...
                { 'fft', 'mcd'} };
                
gausstypes={'diag', 'full'};

gausscomps={[10,30,50], [1,3,5]};        


gauss_retries=5;

spectrum_dim=1024;

curve_smoothing_coeff=0.6;
