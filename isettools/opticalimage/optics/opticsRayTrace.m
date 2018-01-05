function oi = opticsRayTrace(scene,oi)
%Ray trace from scene to oi; includes distortion, relative illum and PSF
%
%   oi = opticsRayTrace(scene,oi)
%
% Use ray trace information, say generated by Code V or Zemax lens design
% programs, to compute the optical image irradiance.  See the routines
% rtGeometry and rtApplyPSF for the algorithms applied.
%
% See also:  oiCompute, rtPrecomputePSFApply, rtPrecomputePSF
%
% Example:
%
% Copyright ImagEval Consultants, LLC, 2003.

if notDefined('scene'), scene = vcGetObject('scene'); end
if notDefined('oi'),    oi = vcGetObject('oi');       end
if isempty(which('rtRootPath')), error('Ray Trace routines not found'); end

% Clear out the in window message
handles = ieSessionGet('opticalimagehandle');
ieInWindowMessage('',handles);

optics = oiGet(oi,'optics');

if isempty(opticsGet(optics,'rayTrace'))
    % No ray trace data available
    ieInWindowMessage('Use Optics | Import to get ray trace information.',handles,3);
    %delete(wBar);
    return;
end
% Ray trace data are available.  Carry on.

% The oi and optics must both have the scene spectrum.  It is annoying that
% there is both an optics and an oi spectrum.  Sigh.
oi     = oiSet(oi,'spectrum',sceneGet(scene,'spectrum'));
optics = opticsSet(optics,'spectrum',oiGet(oi,'spectrum'));
oi     = oiSet(oi,'optics',optics);

% I am not sure why we calculate this here, and we why aren't accounting
% for the padding.
oi = oiSet(oi,'wangular',sceneGet(scene,'wangular'));

% Check that the ray trace data were calculated to a field of view
% equal or greater than the scene fov.
rtFOV    = opticsGet(optics,'rtdiagonalfov');
sceneFOV = sceneGet(scene,'diagonalFieldOfView');
if sceneFOV > rtFOV,
    str = sprintf('Scene diag fov (%.0f) exceeds max RT fov (%.0f)',sceneFOV,rtFOV);
    ieInWindowMessage(str,handles,2);
    %close(wBar);
    return;
end
% We have enough of a field of view.  Carry on again.

sceneDist = sceneGet(scene,'distance');  %m

% Check whether the rt calculations and the scene are for the same depth.
% Usually this is a small thing because we are at infinity in both cases.
rtDist = opticsGet(optics,'rtObjectDistance','m');
if rtDist ~= sceneDist
    delay = 1.5;
    str = sprintf('Scene distance (%.2f m) does not match ray trace assumption (%.2f m)',sceneDist,rtDist);
    ieInWindowMessage(str,handles,delay);
    ieInWindowMessage('Adjusting scene distance.',handles,delay);
    scene = sceneSet(scene,'distance',rtDist);
    vcReplaceObject(scene);
    % sceneWindow;
end

% We calculate the ray traced output in the order of 
%  (a) Geometric distortion, 
%  (b) Relative illumination, and 
%  (c) OTF blurring 

% The function rtGeometry calculates the distortion and relative
% illumination at the same time. 
fprintf('Geometric distortion ...');
irradiance = rtGeometry(scene,optics);
fprintf('\n');
if isempty(irradiance), close(wBar); return; end  % Error condition
% figure; img = imageSPD(irradiance,oiGet(oi,'wave')); imagesc(img)

% Copy the geometrically distorted irradiance data into the optical image
% structure 
oi = oiSet(oi,'photons',irradiance);

% Pre-compute the OTF
% We need to let the user set the angStep in the interface.  This is a good
% default.
angStep = 10;

% Precompute the sample positions PSFs
% Should this be part of optics or oi?
psfStruct = oiGet(oi,'psfStruct');
if isempty(psfStruct)
    fprintf('Pre-computing PSFs...');
    psfStruct = rtPrecomputePSF(oi,angStep);
    oi = oiSet(oi,'psfStruct',psfStruct);
    fprintf('Done precomputing PSFs.\n');
else
    fprintf('Starting with existing PSFs ...\n');
end
% psfMovie(oiGet(oi,'optics'));

% Apply the OTF to the irrad data.
fprintf('Applying PSFs.\n');             % vcAddAndSelectObject(oi); oiWindow;
[irrad, oi] = rtPrecomputePSFApply(oi);  % imageSPD(irrad,550:100:650);
oi = oiSet(oi,'photons',double(irrad));  % 
fprintf('Done applying PSFs.\n');        % vcAddAndSelectObject(oi); oiWindow;

% Do we have an anti-alias filter in place?
switch lower(oiGet(oi,'diffuserMethod'))
    case 'blur'
        %waitbar(0.75,wBar,'OI-RT: Diffuser');
        blur = oiGet(oi,'diffuserBlur','um');
        if ~isempty(blur), oi = oiDiffuser(oi,blur); end
    case 'birefringent'
        % waitbar(0.75,wBar,'OI-RT: Birefringent Diffuser');
        oi = oiBirefringentDiffuser(oi);
    case 'skip'
    otherwise
        error('Unknown diffuser method')
end

% Not sure these should be done here.
[illuminance,meanIlluminance] = oiCalculateIlluminance(oi);

oi = oiSet(oi,'illuminance',illuminance);
oi = oiSet(oi,'meanilluminance',meanIlluminance);

end