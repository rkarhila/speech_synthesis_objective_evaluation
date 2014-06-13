#!/usr/bin/python

BLIZZARD2010="/data/users/rkarhila/blizzard_results/blizzard_wavs_and_scores_2010_release_version_1"
EVALUATION="/data/users/rkarhila/speech_synthesis_objective_evaluation/"


import csv,re,os

dirlist=os.listdir(BLIZZARD2010)

for lng in ["english", "mandarin"]:
    for csvfile in dirlist:
        if re.match(r'^'+lng+r'.*csv',csvfile):
            
            with open(BLIZZARD2010+'/'+csvfile, 'rb') as csvfile:
                reader = csv.reader(csvfile, delimiter='|')
                columns= zip(*reader)

            tasks={"sim":{},"nat":{}}

            for column in columns:

                p=re.search('result\_(01|02)',column[0])
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

                    tfile=open(EVALUATION+'/tests/2010/2010_'+taskname+'_'+test+'.test.scp','w')
                    rfile=open(EVALUATION+'/tests/2010/2010_'+taskname+'_'+test+'.ref.scp','w')


                    for syst in sorted(tasks[test][task]['systems']):
                        taskdir=re.sub('[\(\)]','',task)
                        if syst != "A":
                            ok=True
                            # Check that the files exist and are readable:
                            for sent in tasks[test][task]['sentences']:
                                filename=BLIZZARD2010+'/'+re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/'+lng+'/'+taskdir+r'/2010/\1/wavs/\1_\2.wav', sent)
                                #print filename
                                if not os.access(filename, os.R_OK):
                                    ok=False

                            if ok:
                                for sent in tasks[test][task]['sentences']:
                                    tfile.write(re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/'+lng+'/'+taskdir+r'/2010/\1/wavs/\1_\2.wav', sent)+"\n")
                                    rfile.write(re.sub(r'([^_]+)\_(.*)', 'A'+'/submission_directory/'+lng+'/'+taskdir+r'/2010/\1/wavs/\1_\2.wav',sent)+"\n")

                                systems.append(syst)
                    tfile.close()
                    rfile.close()

                    sfile=open(EVALUATION+'/tests/2010/2010_'+taskname+'_'+test+'.systems','w')
                    for i in sorted(systems):
                        sfile.write(i)
                    sfile.close()


