

interesting_testlist=[3, 6, 11,13,18,47,54, 48, 62, 49, 35, 42, 53, 64, 57]


wrong_outliers={ {}, {}, {}   };
undecided_outliers={ {}, {}, {}   };


wrong_outlier_source={ [], [], []   };
undecided_outlier_source={ [], [], []   };


for method=interesting_testlist;
    for systemtype=1:3
        outl_labs={outliers_for_analysis{method,systemtype}.labs}'
        outl_class=outliers_for_analysis{method,systemtype}.class
    
        wrong_outliers{systemtype}=[wrong_outliers{systemtype}; outl_labs(outl_class==-1)]
        wrong_outlier_source{systemtype}=[wrong_outlier_source{systemtype}; method*ones(size(outl_labs(outl_class==-1)))] ;

        undecided_outliers{systemtype}=[undecided_outliers{systemtype}; outl_labs(outl_class==0)]
        undecided_outlier_source{systemtype}=[undecided_outlier_source{systemtype}; method*ones(size(outl_labs(outl_class==0)))] ;
        
    end
end

popular_outliers=cell(2,3);
outlier_popularity=cell(2,3);
popular_outlier_sources=cell(2,3);

for comptype=1:3
    for foo=1:2
        clear sorted_outliers
        if foo==1
            [sorted_outliers, keys]=sort(wrong_outliers{comptype});
            sorted_sources=wrong_outlier_source{comptype}(keys);
        else
            [sorted_outliers, keys]=sort(undecided_outliers{comptype});
            sorted_sources=undecided_outlier_source{comptype}(keys);
        end

        if length(sorted_outliers)>0
            uniq_outliers={sorted_outliers{1}};
            outl_sources={sorted_sources(1)};


            index=1;
            outl_source_len=[];

            for n=2:length(sorted_outliers)
                if strcmp(sorted_outliers{n},sorted_outliers{n-1})        
                    outl_sources{index}=[outl_sources{index}, sorted_sources(n)];       
                else
                    outl_source_len(index)= length(outl_sources{index});
                    index=index+1;
                    uniq_outliers{index}=sorted_outliers{n};
                    outl_sources{index}=sorted_sources(n);
                end
            end
            outl_source_len(index)=length(outl_sources{index});

            [outl_popularity, keys]=sort(outl_source_len, 'descend');
            popular_outliers{foo, comptype}=uniq_outliers(keys)';
            outlier_popularity{foo, comptype}=outl_popularity;   
            popular_outlier_sources{foo, comptype}=outl_sources(keys);
          end
    end
end


outlier_classes={'Wrong';'Undecided'}

for comptype=1:3
    for foo=1:2
        disp('---');
        disp(['Outlier class: ',outlier_classes{foo}, ' looking at ',comptypes{comptype}])
        for n=1:length(popular_outliers{foo, comptype})            
            src=popular_outlier_sources{foo, comptype}{n};
            disp([num2str(outlier_popularity{foo, comptype}(n)), '  ',popular_outliers{foo, comptype}{n}, ' ', num2str(popular_outlier_sources{foo, comptype}{n})]);
        end
    end
end