#!/usr/bin/python

BLIZZARD2009="/data/users/rkarhila/blizzard_results/blizzard_wavs_and_scores_2009_release_version_1"
EVALUATION="/data/users/rkarhila/speech_synthesis_objective_evaluation/"


import csv,re


for lng in ["english", "mandarin"]:

    with open(BLIZZARD2009+'/'+lng+'_results_for_distribution.csv', 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter='|')
        columns= zip(*reader)

    tasks={"sim":{},"nat":{}}

    for column in columns:

        p=re.search('result\_(01|02)',column[0])
        if p:
            test="sim"
        else:
            p=re.search('result\_(04|05)',column[0])
            if p:
                test="nat"
            else:
                test=None

        if test:
            for row in column[1:]:
                row=re.sub(r'\((.*)\/\)',r'/(\1)/', row)
                row=re.sub('\(processed\)','',row)
                taskandsentandsystem=re.search('(\w.+)\/([^:]+):(.)',row)
                if taskandsentandsystem:
                    task=taskandsentandsystem.group(1)
                    sent=taskandsentandsystem.group(2)
                    syst=taskandsentandsystem.group(3)

                    if not task in tasks[test]:
                        tasks[test][task]={'systems':[], 'sentences':[]}
                    if not sent in tasks[test][task]['sentences']:
                        tasks[test][task]['sentences'].append(sent)
                    if not syst in tasks[test][task]['systems']:
                        tasks[test][task]['systems'].append(syst)



    for test in tasks.keys():                        
        for task in tasks[test].keys():
            print task
            taskname=re.sub('\/\(.*','', task)

            tfile=open(EVALUATION+'/tests/2009/2009_'+taskname+'_'+test+'.test.scp','w')
            rfile=open(EVALUATION+'/tests/2009/2009_'+taskname+'_'+test+'.ref.scp','w')

            for syst in tasks[test][task]['systems']:
                taskdir=re.sub('[\(\)]','',task)
                if syst != "A":
                    for sent in tasks[test][task]['sentences']:
                        tfile.write(re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/'+lng+'/'+taskdir+r'/2009/\1/wavs/\1_\2.wav', sent)+"\n")
                        rfile.write(re.sub(r'([^_]+)\_(.*)', 'A'+'/submission_directory/'+lng+'/'+taskdir+r'/2009/\1/wavs/\1_\2.wav',sent)+"\n")


            tfile.close()
            rfile.close()

