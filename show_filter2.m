function [ output_args ] = show_filter( tensor )

figure;
if length(size(tensor))==5
    w1 = squeeze(tensor(1,:,:,:,1));%W(1,:,:,:);
else
    w1 = squeeze(tensor(1,:,:,:));%W(1,:,:,:);
end
h = vol3d('cdata',w1,'texture','3D');
% colormap(bone(256));
view(3); % Update view since 'texture' = '2D'
vol3d(h);  
alphamap('rampdown'), alphamap('decrease'), alphamap('decrease')
axis equal;  daspect([1 1 1])
alphamap(0.1 .* alphamap);
% alphamap('rampup');

% alphamap('rampdown'), alphamap('decrease'), alphamap('decrease')
% alphamap(0.1 .* alphamap);


end

