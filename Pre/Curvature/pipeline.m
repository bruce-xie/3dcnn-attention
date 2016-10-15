
    str = [''];
    json2data = loadjson(str);
    v = json2data.parsed.vertexArray;
    f = json2data.parsed.faceArray+1; % index from .json starts from 0, but required to be 1 for meshSaliencyPipeline
    m = struct('v',v,'f',f);
    [meshSaliency, az, el, az2, el2] = meshSaliencyPipeline(m);
