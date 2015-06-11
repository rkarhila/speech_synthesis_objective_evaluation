
%set(hFig,'WindowButtonMotionFcn', {@display_data_label,hFig, HA, annot, smoothed_vals, labs_for_smoothed_vals})
% annot=annotation('textbox', [1,1,0,0], 'String', '');
% set(annot,'BackgroundColor','white')
% set(annot,'EdgeColor','blue')

function  [] = display_data_label(varargin)

foo1=varargin{1};
foo2=varargin{2};
Hfig=varargin{3};
foo4=varargin{4};

annot=varargin{5};
smoothed_vals=varargin{6};
labs_for_smoothed_vals=varargin{7};


cp0=get(Hfig, 'currentpoint');
cp1=(get(foo4{1}, 'currentpoint'));
cp2=(get(foo4{2}, 'currentpoint'));
cp3=(get(foo4{3}, 'currentpoint'));

xlim1=get(foo4{1},'xlim');
xlim2=get(foo4{2},'xlim');
xlim3=get(foo4{3},'xlim');

ylim1=get(foo4{1},'ylim');
ylim2=get(foo4{2},'ylim');
ylim3=get(foo4{3},'ylim');

dodraw=1;



if cp1(1,2)< ylim1(2) && cp1(1,2) > ylim1(1) && cp1(1,1) > xlim1(1) && cp1(1,1) < xlim1(2)
    %set(annot,'Units','normalized') 
    cp=cp1;
    labelindex=1;
    ylim=ylim1;
    xlim=xlim1;
elseif cp2(1,2)< ylim2(2) && cp2(1,2) >  ylim2(1) && cp2(1,1) > xlim2(1) && cp2(1,1) < xlim2(2)
    %disp('Mouse in plot 2');   
    cp=cp2;
    labelindex=2;
    ylim=ylim2;
    xlim=xlim2; 
elseif cp3(1,2)< ylim3(2) && cp3(1,2) >  ylim3(1) && cp3(1,1) > xlim2(1) && cp3(1,1) < xlim3(2)
    cp=cp3;
    labelindex=3;
    ylim=ylim3;
    xlim=xlim3;     
else
    dodraw=0;
end

if dodraw   
    xpoints=smoothed_vals{labelindex}{1};
    ypoints=smoothed_vals{labelindex}{2};
    labs=labs_for_smoothed_vals{labelindex};

    thr=0.02*(xlim(2)-xlim(1));
    ythr=0.02*(ylim(2)-ylim(1));
    
    for i=1:length(xpoints)
        if (cp(1,1)>xpoints(i)-thr) && (cp(1,1)<xpoints(i)+thr)
            if (cp(1,2)>ypoints(i)-ythr) && (cp(1,2)<ypoints(i)+ythr)
                set(annot,'LineWidth',1)
                set(annot,'EdgeColor','blue')
                set(annot,'Units','pixels')
                set(annot,'Position', [cp0(1), cp0(2), 0, 0]);
                set(annot,'Interpreter','none');
                set(annot,'String',labs(i));
            else
                break
            end
        else
            continue
        end
    end
else
    set(annot,'Position', [0, 0, 0, 0]);
end


