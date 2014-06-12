function [ saved_item ] = parload( fname )
  if(exist([fname,'.mat'], 'file'))
   load([fname,'.mat'],'-mat');
  else
   saved_item=load(fname,'-ascii');
  end    
end

