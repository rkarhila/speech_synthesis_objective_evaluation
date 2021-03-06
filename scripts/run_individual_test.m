function [results] = run_individual_test(test_specs, path_prefix)
    %local_conf
    
    disp(['Running test ', test_specs.name])
    
    if exist(test_specs.objective_resultfile, 'file') == 0;   

        invasive_file=[test_specs.objective_resultfile,'.invasive'];
        if exist(invasive_file, 'file') == 0;   
            [ invasive_measure_result, inv_test_runtime] = ...
                evaluate_with_invasive_measures(path_prefix, test_specs.reffilelist,test_specs.testfilelist);        
            save(invasive_file, 'invasive_measure_result','-ascii');       
        else
            invasive_measure_result=load(invasive_file);
        end
        
         
        non_invasive_traditional_file=[test_specs.objective_resultfile,'.non_invasive_trad'];
        if exist(non_invasive_traditional_file, 'file') == 0;         
        
            [ non_invasive_traditional_measure_result, non_inv_test_runtime] = ...
                evaluate_with_non_invasive_measures_trad_order(path_prefix, test_specs.reffilelist,test_specs.testfilelist);              
            save(non_invasive_traditional_file, 'non_invasive_traditional_measure_result','-ascii');       
        else
            non_invasive_traditional_measure_result=load(non_invasive_traditional_file);
        end
       

        
        
        non_invasive_reverse_file=[test_specs.objective_resultfile,'.non_invasive'];
        if exist(non_invasive_reverse_file, 'file') == 0;         
        
            [ non_invasive_reverse_measure_result, non_inv_test_runtime] = ...
                evaluate_with_non_invasive_measures_rev_order(path_prefix, test_specs.reffilelist,test_specs.testfilelist);              
            save(non_invasive_reverse_file, 'non_invasive_measure_result','-ascii');       
        else
            non_invasive_reverse_measure_result=load(non_invasive_reverse_file);
        end

        
        
        
        pesq_file=[test_specs.objective_resultfile,'.pesq'];
        if exist(pesq_file, 'file') == 0;         
            [ pesq_result, pesq_test_runtime] = ...
                evaluate_with_pesq(path_prefix, test_specs.reffilelist,test_specs.testfilelist);        
            save(pesq_file, 'pesq_result','-ascii');       
        else
            pesq_result=load(pesq_file);
        end
        
        objdata=[ invasive_measure_result, non_invasive_reverse_measure_result, non_invasive_traditional_measure_result', pesq_result ];
        save(test_specs.objective_resultfile, 'objdata','-ascii');
        results=objdata;
    else      
        disp(['Loading results from ',test_specs.objective_resultfile])
        results=load(test_specs.objective_resultfile);
        
    end
    
    %scores=evaluate_wilcoxon(test_specs.results, load(test_specs.subjective_resultfile), load(test_specs.opinionmatrix), ...
    %                           test_specs.systems, 0);
