#!/usr/bin/python

BLIZZARD2008="/data/users/rkarhila/blizzard_results/blizzard_wavs_and_scores_2008_release_version_1"
EVALUATION="/data/users/rkarhila/speech_synthesis_objective_evaluation/"


import csv,re,os


for lng in ["english"]:

    with open(BLIZZARD2008+'/'+lng+'_results_for_distribution.csv', 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter='|')
        columns= zip(*reader)

    tasks={"sim":{},"nat":{}}

    for column in columns:

        p=re.search('result\_(01)',column[0])
        if p:
            test="sim"
        else:
            p=re.search('result\_(03|04|05)',column[0])
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

            systems=[]

            tfile=open(EVALUATION+'/tests/2008/2008_'+lng+"_"+taskname+'_'+test+'.test.scp','w')
            rfile=open(EVALUATION+'/tests/2008/2008_'+lng+"_"+taskname+'_'+test+'.ref.scp','w')


            for syst in sorted(tasks[test][task]['systems']):
                taskdir=re.sub('[\(\)]','',task)
                if syst != "A":
                    ok=True
                    # Check that the files exist and are readable:
                    for sent in tasks[test][task]['sentences']:
                        filename=BLIZZARD2008+'/'+re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/'+lng+'/'+taskdir+r'/2008/\1/\1_\2.wav', sent)

                        
                        if not os.access(filename, os.R_OK):
                            print "Not ok: "+filename
                            ok=False
                        
                    if ok:
                        for sent in tasks[test][task]['sentences']:
                            tfile.write(re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/'+lng+'/'+taskdir+r'/2008/\1/\1_\2.wav', sent)+"\n")
                            rfile.write(re.sub(r'([^_]+)\_(.*)', 'A'+'/submission_directory/'+lng+'/'+taskdir+r'/2008/\1/\1_\2.wav',sent)+"\n")

                        systems.append(syst)
            tfile.close()
            rfile.close()

            sfile=open(EVALUATION+'/tests/2008/2008_'+taskname+'_'+test+'.systems','w')
            for i in sorted(systems):
                sfile.write(i)
            sfile.close()





for lng in ["mandarin"]:

    with open(BLIZZARD2008+'/'+lng+'_results_for_distribution.csv', 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter='|')
        columns= zip(*reader)

    tasks={"sim":{},"nat":{}} 

    for column in columns:

        p=re.search('result\_(01)',column[0])
        if p:
            test="sim"
        else:
            p=re.search('result\_(03|04)',column[0])
            if p:
                test="nat"
            else:
                test=None

        if test:
            for row in column[1:]:
                row=re.sub(r'\((.*)\/\)',r'/(\1)/', row)
                row=re.sub('\(processed\)','',row)
                taskandsentandsystem=re.search(' ([^:]+):(.)',row)
                if taskandsentandsystem:
                    task="mandarin"
                    sent=taskandsentandsystem.group(1)
                    syst=taskandsentandsystem.group(2)

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

            systems=[]

            tfile=open(EVALUATION+'/tests/2008/2008_'+taskname+'_'+test+'.test.scp','w')
            rfile=open(EVALUATION+'/tests/2008/2008_'+taskname+'_'+test+'.ref.scp','w')


            for syst in sorted(tasks[test][task]['systems']):
                taskdir="news/" # re.sub('[\(\)]','',task)
                if syst != "A":
                    ok=True
                    # Check that the files exist and are readable:
                    for sent in tasks[test][task]['sentences']:
                        filename=BLIZZARD2008+'/'+re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/'+lng+'/2008/'+r'\1/\1_\2.wav', sent)

                        
                        if not os.access(filename, os.R_OK):
                            print "Not ok: "+filename
                            ok=False
                        
                    if ok:
                        for sent in tasks[test][task]['sentences']:
                            tfile.write(re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/'+lng+'/'+r'/2008/\1/\1_\2.wav', sent)+"\n")
                            rfile.write(re.sub(r'([^_]+)\_(.*)', 'A'+'/submission_directory/'+lng+'/'+r'/2008/\1/\1_\2.wav',sent)+"\n")

                        systems.append(syst)
            tfile.close()
            rfile.close()

            sfile=open(EVALUATION+'/tests/2008/2008_'+taskname+'_'+test+'.systems','w')
            for i in sorted(systems):
                sfile.write(i)
            sfile.close()
