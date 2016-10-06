
function v = sal(Mesh)
% given a mesh structure {v,f}
% compute saliency value "v" on all vertices

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