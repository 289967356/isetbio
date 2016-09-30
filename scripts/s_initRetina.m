%% Initialize a set of ISETBIO objects for developing
%
% Sometimes we just want to have the complement of objects from scene to oi
% to cmosaic to bipolar to retinal ganglion cells mosaics.  
%
% If you run this script, a usable collection of all these objects will be
% produced.
%
%    scene, oi, cmosaic, bp, rgc
%
% BW ISETBIO Team, 2016

%% TODO
% Some routines are returning an 'ans' when they run.  I am deleting it,
% but we should figure out which routine is producing the ans and get rid
% of it.  In fact, there are several.  Likely the 'compute' routines.

%%
ieInit;
clx;

%% All the way from scene to inner retina 
scene = sceneCreate('rings rays');
scene = sceneSet(scene,'fov',2);
% ieAddObject(scene); sceneWindow;

oi = oiCreate;
oi = oiCompute(oi,scene);
% ieAddObject(oi); oiWindow;

cmosaic = coneMosaic;
cmosaic.emGenSequence(50);
cmosaic.compute(oi); clear a;
% cmosaic.window

bp = bipolar(cmosaic);
bp.compute(cmosaic);

clear params rgc
cellType = 'onParasol';
params.name = 'test';
params.eyeSide = 'left'; 
params.eyeRadius = 0; 
params.eyeAngle  = 0; 
ntrials = 1;

% Create inner retina object with ganglion cell mosaics
rgc = ir(bp, params);
rgc.mosaicCreate('type',cellType,'model','LNP');
rgc.compute(bp);

% When debugging coneMosaicHex
resampleF = 2;
cmosaicH = coneMosaicHex(resampleF,false);
cmosaicH.emGenSequence(50);
cmosaicH.compute(oi); clear a;

%% Clear and list the objects
clear ntrial params ans

whos
