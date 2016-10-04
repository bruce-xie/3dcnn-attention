function instance=show_sal(meshfile)
% visualize both meshed object and its saliency computed by curvature
% method
if strcmp(meshfile(end-2:end),'off')
    FV = off_loader(meshfile, 0);
    Mesh = struct('v',FV.vertices,'f',FV.faces);
elseif strcmp(meshfile(end-2:end),'son')
    json2data = loadjson(['/media/storage/p2admin/Documents/Hope/voxnet/Pre/voxelization' filesep '392.json']);
    v = json2data.parsed.vertexArray;
    f = json2data.parsed.faceArray+1; % index from .json starts from 0, but required to be 1 for meshSaliencyPipeline
    FV = struct('vertices',v,'faces',f);
    Mesh = struct('v',v,'f',f);
else
    assert(0);
end
v = sal(Mesh);
vis(FV,v)

volume_size = 30;
instance = polygon2voxel(FV, [volume_size, volume_size, volume_size], 'auto');

lowres_fv = isosurface(the_sample,threshold);
vis(instance,v)
show_sample(instance,0.5)
end

function vis(FV,v)
p = patch(FV);
p.FaceVertexAlphaData = v;
p.FaceAlpha = 'interp';
p.FaceVertexCData=v;
set(p,'FaceColor','red','EdgeColor','none');
daspect([1,1,1])
grid on; axis tight
camlight
lighting gouraud;

axis equal
axis vis3d
%     view(2);
%     axis([0 30 0 30 0 30])
zlabel('z');
xlabel('x');
ylabel('y');
%     axis tight;
%     pause;
%     close(gcf);
view(90,0)
end

function v = sal(Mesh)
global cache_ params_;
cache_ = struct();
params_.scale = 0.003;
params_.windowSize = 0.33 * sqrt(sum((min(Mesh.v)-max(Mesh.v)).^2));
curvature = computeCurvature(Mesh);
epsilon = params_.scale * sqrt(sum((min(Mesh.v)-max(Mesh.v)).^2));
suppressedLevelSaliency = {};
for level = 1:5
    sigma = round((level+1) * epsilon, 6);
    levelSaliency = centerSurround(Mesh, curvature, sigma);
    suppressedLevelSaliency{level} = nonlinearSuppression(Mesh, levelSaliency, sigma);
end
v = sum(cat(2,suppressedLevelSaliency{:}),2);

end