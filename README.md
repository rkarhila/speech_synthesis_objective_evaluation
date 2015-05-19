# speech_synthesis_objective_evaluation #

Tools for evaluating the quality of synthetic speech 
(and particularly the ISCA SynSIG Blizzard challenge). 
Text-To-Speech systems using synthetic voices trained
on an audio corpus are usually evaluated in listening 
tests, where volunteers listen to samples from different
systems and evaluate them based on their naturalness 
and similarity to the speaker in the training corpus.

Objective evaluation methods based on some measure of
distortion between a natural speech sample and the
synthetic, TTS generated sample are used in system
development.

This toolkit provides:

* Framework for use of different objective evaluation
  methods
* Statistics on the meaningfullness of different 
  distortion and similarity measusres ie. what level
  of difference is likely to be detected in a listening
  test?


## Features ##

* Acoustic distance measures
  * mcd
  * fwSNRseg
  * wrapper for COLEA stuff
  * wrapper for external, efficient DTW
* synthetic speaker GMM training
* wrapper for external PESQ wrapper


## Warning: ##

This is research software: Slow and awkward, but easily 
extensible.


## How this thing works ##

* Clone this repo
* Run **donwload_includes.sh** to download external 
  components
* Download the Blizzard challenge result releases from 
  http://www.cstr.ed.ac.uk/projects/blizzard/data.html 
  and unpack.
* Copy the **conf.m.example** file into **conf.m** and 
  set your paths.
* Run **run_tests.m** in Matlab and after some time, 
  pretty pictures will be drawn and saved.
* Include your own evaluation method in the correct 
  place:
  * conf file
  * scripts/extract_nn.m (...)


### What happens then ie. evaluation workflow ###

1. **run_tests.m** calls all the **evaluate_test_20nn.m**
  scripts
2. **evaluate_test_20nn.m** has all the relevant data
  about file lists and result files related to that 
  year's challenge, and calls **obj_evaluation.m:**
  * **obj_evaluation.m:** processes first the ** *non-invasive
    tests* ** (ie. GMM):
    * Feature extraction for synthetic speech: **calculate_feas.m**
    * GMM training: **gmmb_em_d.m** and **gmmb_em.m**
    * GMMs are stored in a struct *par_gaussians*
  * Then ** *invasive tests* **
    * Feature extraction for natural reference speech: **calculate_feas.m**
    * Distance maps between reference and test samples: **make_dist_map.m**
    * DTW with **dpfast.m**
    * Calculation of error along path
  * Then PESQ with **pesqbin.m**
3. **evaluate_test_20nn.m** also calls **evaluate_wilcoxon.m:**

## Some notes on the data: ##

Developed and tested on the data released in ISCA SynSIG 
Blizzard challenges 2008-2012.

#### 2009 results: ####
Mandarin applicant F's files seem to be corrupted and so have been left out.

