#!/bin/bash

cd /data/users/rkarhila/blizzard_results/blizzard_wavs_and_scores_2013_release_version_1

# EH1 01_ 0023|0007|0100|0074|0021|0098|0058|0071|0029|0094|0001

find -name "*.wav" | egrep 'booksent_2013_(0023|0007|0100|0074|0021|0098|0058|0071|0029|0094|0001)' | sort | grep -v '/A/' | grep EH1 > /data/users/rkarhila/speech_synthesis_objective_evaluation/tests/2013/2013_EH1_sim.test.scp

# EH1 02_ 0040|0015|0064|0038|0014|0056|0027|0019|0010|0062|0091
# EH1 04_ 0013|0037|0044|0009|0026|0008|0028|0004|0081|0041|0099
# EH1 06_ 0054|0045|0046|0070|0065|0052|0095|0017|0049|0093|0031

find -name "*.wav" | egrep 'booksent_2013_(0040|0015|0064|0038|0014|0056|0027|0019|0010|0062|0091|0013|0037|0044|0009|0026|0008|0028|0004|0081|0041|0099|0054|0045|0046|0070|0065|0052|0095|0017|0049|0093|0031)' | sort | grep -v '/A/' | grep EH1 > /data/users/rkarhila/speech_synthesis_objective_evaluation/tests/2013/2013_EH1_nat.test.scp


# EH2 01_ 0036|0040|0015|0064|0038|0014|0056|0027|0019|0010|0062|0091|0013|0037|0036

find -name "*.wav" | egrep 'booksent_2013_(0036|0040|0015|0064|0038|0014|0056|0027|0019|0010|0062|0091|0013|0037|0036)' | sort | grep -v '/A/' | grep EH2 > /data/users/rkarhila/speech_synthesis_objective_evaluation/tests/2013/2013_EH2_sim.test.scp


# EH2 02_ 0005|0012|0059|0076|0086|0068|0060|0055|0097|0042|0006|0051|0018|0020|0079
# EH2 04_ 0032|0080|0083|0048|0078|0002|0061|0073|0075|0035|0033|0096|0085|0087|0016


find -name "*.wav" | egrep 'booksent_2013_(0005|0012|0059|0076|0086|0068|0060|0055|0097|0042|0006|0051|0018|0020|0079|0032|0080|0083|0048|0078|0002|0061|0073|0075|0035|0033|0096|0085|0087|0016)' | sort | grep -v '/A/' | grep EH2 > /data/users/rkarhila/speech_synthesis_objective_evaluation/tests/2013/2013_EH2_nat.test.scp


for file in /data/users/rkarhila/speech_synthesis_objective_evaluation/tests/2013/2013_*.test.scp; do sed -r 's/(\/)[B-Z](\/)/\1A\2/g' $file  > /data/users/rkarhila/speech_synthesis_objective_evaluation/tests/2013/`basename $file .test.scp`.ref.scp; done
