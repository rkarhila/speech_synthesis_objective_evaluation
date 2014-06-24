#!/usr/bin/python

BLIZZARD2012="/data/users/rkarhila/blizzard_results/blizzard_wavs_and_scores_2012/afs/.inf.ed.ac.uk/group/blizzard/blizzard_2012/analysis/distribution/full_distribution/"

EVALUATION="/data/users/rkarhila/speech_synthesis_objective_evaluation/"


import csv,re,os

dirlist=os.listdir(BLIZZARD2012)

for csvfile in [BLIZZARD2012+ "test_results/sim_and_mos.csv"]:
#for lng in ["english", "mandarin"]:
#    for csvfile in dirlist:
#        if re.match(r'^'+lng+r'.*csv',csvfile):
            
            with open(csvfile, 'rb') as csvfile:
                reader = csv.reader(csvfile, delimiter='|')
                columns= zip(*reader)

            tasks={"sim":{},"nat":{}}

            for column in columns:

                p=re.search('result\_(01)',column[0])
                if p:
                    test="sim"
                else:
                    p=re.search('result\_(02|03|04|05)',column[0])
                    if p:
                        test="nat"
                    else:
                        test=None

                if test:
                    for row in column[1:]:
                        row=re.sub(r'\((.*)\/\)',r'/(\1)/', row)
                        row=re.sub('\(processed\)','',row)
                        taskandsentandsystem=re.search(' (([^_]+)\_[^:]+):(.)',row)
                        if taskandsentandsystem:
                            sent=taskandsentandsystem.group(1)
                            task=taskandsentandsystem.group(2)
                            print task
                            #task="EH1"
                            syst=taskandsentandsystem.group(3)

                            if not task in tasks[test]:
                                tasks[test][task]={'systems':[], 'sentences':[]}
                            if not sent in tasks[test][task]['sentences']:
                                tasks[test][task]['sentences'].append(sent)
                            if not syst in tasks[test][task]['systems']:
                                tasks[test][task]['systems'].append(syst)



            for test in tasks.keys():                        
                

                for task in tasks[test].keys():

                    tfile=open(EVALUATION+'/tests/2012/2012_'+task+'_'+test+'.test.scp','w')
                    rfile=open(EVALUATION+'/tests/2012/2012_'+task+'_'+test+'.ref.scp','w')

                    print test + " " + task
                    #taskname=re.sub('\/\(.*','', task)

                    systems=[]



                    for syst in sorted(tasks[test][task]['systems']):
                        taskdir=re.sub('[\(\)]','',task)
                        #print taskdir
                        if syst != "A":
                            audiobook_renaming=False
                            ok=True
                            # Check that the files exist and are readable:
                            for sent in tasks[test][task]['sentences']:
                                #print "looking for "+ BLIZZARD2012+'/'+re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/2012'+r'/\1/wav/\1_\2.wav', sent)
                                filename=BLIZZARD2012+'/'+re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/2012'+r'/\1/wav/\1_\2.wav', sent)
                                #print filename
                                if not os.access(filename, os.R_OK):
                                    audiobook_renaming=True
                                    filename=BLIZZARD2012+'/'+re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/2012'+r'/audiobook_sentences/wav/\1_\2.wav', sent)
                                    if not os.access(filename, os.R_OK):
                                        ok=False

                            if ok:
                                for sent in tasks[test][task]['sentences']:
                                    if audiobook_renaming:
                                        tfile.write(re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/2012'+r'/audiobook_sentences/wav/\1_\2.wav', sent)+"\n")
                                    else:
                                        tfile.write(re.sub(r'([^_]+)\_(.*)', syst+'/submission_directory/2012'+r'/\1/wav/\1_\2.wav', sent)+"\n")

                                    rfile.write(re.sub(r'([^_]+)\_(.*)', 'A'+'/submission_directory/2012'+r'/\1/wav/\1_\2.wav', sent)+"\n")

                                systems.append(syst)
                    tfile.close()
                    rfile.close()

                    sfile=open(EVALUATION+'/tests/2012/2012_'+task+'_'+test+'.systems','w')
                    for i in sorted(systems):
                            sfile.write(i)
                    sfile.close()


