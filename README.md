# speech_synthesis_objective_evaluation #

Tools for evaluating the quality of synthetic speech (and particularly the ISCA SynSIG Blizzard challenge). Text-To-Speech systems using synthetic voices trained on an audio corpus are usually evaluated in listening  tests, where volunteers listen to samples from different systems and evaluate them based on their naturalness and similarity to the speaker in the training corpus.

Objective evaluation methods based on some measure of distortion between a natural speech sample and the synthetic, TTS generated sample are used in system development.

This toolkit provides:

* Framework for use of different objective evaluation   methods
* Statistics on the meaningfullness of different distortion and similarity measusres ie. what level of difference is likely to be detected in a listening test?


## Features ##

* Acoustic distance measures
  * mcd
  * fwSNRseg
  * wrapper for COLEA stuff
  * wrapper for external, efficient DTW
* synthetic speaker GMM training
* wrapper for external PESQ wrapper


## Warning: ##

This is research software: Slow and awkward, but easily extensible.


## How do I get this thing running? ##

* Clone this repo: `git clone https://github.com/rkarhila/speech_synthesis_objective_evaluation`
* Run `download_includes.sh` to download external components
* Download the Blizzard challenge result releases from http://www.cstr.ed.ac.uk/projects/blizzard/data.html and unpack.
* Copy the **conf.m.example** file into **conf.m** and  set your paths.
* Run **run_tests.m** in Matlab and after some time,  pretty pictures will be drawn and saved.

## How do I use my own objective quality measure? ##

* Include your own evaluation method in the correct place. For distortion measures using DTW:
  * Wrap your code in several parts: 
    1. An audio preprocessing function that takes as input **varargin** (1) the name of the audio file, (2) the parameters for and possibly (3) a filename for caching the preprocessed audio. Returns an audio structure with fields 'audio' (the waveform) and 'speech_frames' (list of frames thought to consist of speech).  Example: scripts/prepare_audio.m
    2. A feature extraction function that takes as input **varargin** consting of (1) audio structure and (2) the parameters and possibly (3) a filename for caching features. Returns a structure with fields 'features' (the waveform) and 'speech_frames' (list of frames thought to consist of speech). Example: scripts/analysis_fft_mfcc.m
    3. A distance function that takes as input **varargin** (1) test features, (2) reference features and (3) parameters. Returns a computed frame-by-frame distance map between the two utterances.
  * Include the test specification in the conf-file, like this:

```
% Define the functions and the parameters for your test
% in a struct with obligatory fields
% 'name', 'analysisfunction', 'distancefunction'
% and any parameters you might need:
fft_mcd_distance1.name='fft_mcd1';
fft_mcd_distance1.analysisfunction=@analysis_fft_mfcc;
fft_mcd_distance1.distancefunction=@dist_mcd; 
fft_mcd_distance1.fs = 16000;
fft_mcd_distance1.frame_ms = 25;
fft_mcd_distance1.step_ms =  10;
fft_mcd_distance1.spectrum_dim = 1024;
fft_mcd_distance1.cep_dim = 13;
fft_mcd_distance1.mel_dim = 21;
fft_mcd_distance1.usedelta = 0;


% Include your test in the cell array of "invasive_tests":
%
invasive_tests= { ...
    struct('preprocessing', audio_preprosessing1, ...
           'map_feature', fft_mcd_distance1 , ...
           'path_feature', fft_mcd_distance1 , ...
           'step_matrix', step_matrix1,...
           'name','Distortion: dtw and path with FFT-based MCD' ) };
```

* For non-invasive measures:
  * Wrap your code in several parts: 
    1. Audio preprocessing like above.
    2. Feature extraction like above.
    3. A model training function that takes as input **varargin** consting of (1) features for all the training utterances in one big block and (2) parameters for training, and returns a struct representing the model. Example: scripts/model_train_gmm.m 
    4. A model testing function that takes as input **varargin** consting of (1) the model, (2) the test utterance features and (3) parameters, and returns a score for the utterance. Example: scripts/model_test_gmm.m
  * Include the test specification in the conf-file, like this:

```
% Define the functions and the parameters for your test
% in a structures; First an analysis/feature extraction
% function with obligatory fields 'name' and 
% 'analysisfunction':
fft_mfcc1.name='fft_mfcc_analysis';
fft_mfcc1.analysisfunction=@analysis_fft_mfcc;
fft_mfcc1.fs = 16000;
fft_mfcc1.frame_ms = 25;
fft_mfcc1.step_ms =  10;
fft_mfcc1.spectrum_dim = 1024;
fft_mfcc1.cep_dim = 13;
fft_mfcc1.mel_dim = 21;
fft_mfcc1.usedelta = 1;

% Then the method function with obligatory fields
% 'trainfunction' and 'testfunction'
gmm_diag_10_comp1.name='GMM_diagonal_10_comp';
gmm_diag_10_comp1.cov_type='diag';
gmm_diag_10_comp1.num_components=10;
gmm_diag_10_comp1.trainfunction=@model_train_gmm;
gmm_diag_10_comp1.testfunction=@model_test_gmm;

% Include your test in the cell-array "non_invasive_tests":
%
non_invasive_tests = { ...
      struct('preprocessing', audio_preprosessing1, ...
           'analysis', fft_mfcc1 , ...
           'modelling', gmm_diag_10_comp1 , ...
           'name','gmm diag 10 comp of fft mfcc' ) }
```

  * Note that the model is trained with synthetic speech and tested against the reference. Check the paper for the reason for doing this.

## What if I want to... ##

###...use my own DTW function?###

Either add your own function or rewrite **evaluate_with_invasive_measures.m** to be more modular. Do it well and make a pull request so it can be incorporated in the pacakge.

###...train a model for the reference speech and use it to evaluate the synthetic speech systems? ###

The current scheme is to train a model for the synthetic speech and see how well the reference speech fits it. If you want to do it the other way around, either add your own function or rewrite **evaluate_with_non_invasive_measures.m** to support this reverse order. Do it well and make a pull request so it can be incorporated in the pacakge.




## Some notes on the data: ##

Developed and tested on the data released in ISCA SynSIG 
Blizzard challenges 2008-2012.

#### 2009 results: ####
Mandarin applicant F's files seem to be corrupted and so have been left out.

