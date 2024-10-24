clear all; close all;
if isempty(gcp())
    parpool();
end
nworkers = gcp().NumWorkers;
maxIterations = 1000; gridSize = 2000; 

xlim = [-0.748766713922161, -0.748766707771757];
ylim = [ 0.123640844894862,  0.123640851045266];

num_Blocks = 2; 
block_Size = gridSize / num_Blocks; 

ylim = linspace(ylim(1),ylim(end),num_Blocks+1); 

tic();
spmd
    [blockX, blockY] = ind2sub([num_Blocks, num_Blocks], labindex());
    x = linspace(xlim(1), xlim(2), gridSize);
    y = linspace(ylim(blockY), ylim(blockY+1), block_Size);
    
    [xGrid,yGrid] = meshgrid(x,y);
    z0 = xGrid + 1i*yGrid; count = ones(size(z0));
    
    % Calculate
    z = z0;
    for n = 0:maxIterations
        z = z.*z + z0;
        inside = abs( z ) <= 2; count = count + inside;
    end
    count = log(count);
end

% On the client, Show
cpuTime = toc();
set( gcf,'Position',[200 200 600 600] );
imagesc(cat(2,x{:}),cat(2,y{:}),cat(1,count{:}));
axis image; axis off; colormap([jet();flipud(jet());0 0 0]); drawnow;
title( sprintf('%1.2fsecs (with spmd)',cpuTime));
