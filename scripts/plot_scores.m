

cor_sim=corr(sub_scores_norm_sim,ob_scores_norm_sim);
cor_nat=corr(sub_scores_norm_nat,ob_scores_norm_nat);

if 0
    
fws_sim = cor_sim(1,[1:3 10:12 19:21]);
mcd_sim = cor_sim(1,[4:6 13:15 22:24]);
llr_sim = cor_sim(1,[7:9 16:18 25:27]);

fws_nat = cor_nat(1,[1:3 10:12 19:21]);
mcd_nat = cor_nat(1,[4:6 13:15 22:24]);
llr_nat = cor_nat(1,[7:9 16:18 25:27]);
    
end


[sub_scores_sys_sim_sorted,sub_index_sys_sim_sorted]=sort(sub_scores_sys_sim(:,1),'descend');
[sub_scores_sys_nat_sorted,sub_index_sys_nat_sorted]=sort(sub_scores_sys_nat(:,1),'descend');

systems = 'BCDEHIJKLMOPQRSTUW';


%COLOR OF BARS
barmap=[0 0.7 0.6];

%BAR EDGECOLOR
edge_bars = 'none';

%BAR WIDTH
b_width = 0.5;

figure(30);
subplot(2,1,1);
bar(sub_scores_sys_sim_sorted,b_width,'EdgeColor',edge_bars);
colormap(barmap);
hold on;
errorbar(sub_scores_sys_sim_sorted,1.96*sub_scores_syssed_sim(sub_index_sys_sim_sorted),'.','MarkerSize',0.5)
hold off;
for sindex=1:18
sorted_sys_sim{sindex}=systems(sub_index_sys_sim_sorted(sindex));
end
set(gca,'XTick',[1:18],'XTickLabel',sorted_sys_sim)
title('sub sim')
subplot(2,1,2);
bar(sub_scores_sys_nat_sorted,b_width,'EdgeColor',edge_bars);
hold on;
errorbar(sub_scores_sys_nat_sorted,1.96*sub_scores_syssed_nat(sub_index_sys_nat_sorted),'.','MarkerSize',0.5)
hold off;
for sindex=1:18
sorted_sys_nat{sindex}=systems(sub_index_sys_nat_sorted(sindex));
end
set(gca,'XTick',[1:18],'XTickLabel',sorted_sys_nat)
title('sub nat')


for score_num = [12 15]
    
[ob_scores_sys_sim_sorted,ob_index_sys_sim_sorted]=sort(ob_scores_sys_sim(:,score_num));
[ob_scores_sys_nat_sorted,ob_index_sys_nat_sorted]=sort(ob_scores_sys_nat(:,score_num));

figure(score_num);
subplot(2,1,1);
bar(ob_scores_sys_sim_sorted,b_width,'EdgeColor',edge_bars);
hold on;
errorbar(ob_scores_sys_sim_sorted,1.96*ob_scores_syssed_sim(ob_index_sys_sim_sorted,score_num),'.','MarkerSize',0.5)
hold off;
for sindex=1:18
sorted_sys_sim{sindex}=systems(ob_index_sys_sim_sorted(sindex));
end
set(gca,'XTick',[1:18],'XTickLabel',sorted_sys_sim)
title(['ob sim (\rho =' num2str(abs(cor_sim(1,score_num))) ')'])
subplot(2,1,2);
bar(ob_scores_sys_nat_sorted,b_width,'EdgeColor',edge_bars);
hold on;
errorbar(ob_scores_sys_nat_sorted,1.96*ob_scores_syssed_nat(ob_index_sys_nat_sorted,score_num),'.','MarkerSize',0.5)
hold off;
colormap(barmap);
for sindex=1:18
sorted_sys_nat{sindex}=systems(ob_index_sys_nat_sorted(sindex));
end
set(gca,'XTick',[1:18],'XTickLabel',sorted_sys_nat)
title(['ob nat (\rho =' num2str(abs(cor_nat(1,score_num))) ')'])
end
