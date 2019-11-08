function val = mmSquaredToDegSquared(obj, mmSquared, eccDegs)
% Convert retinal area from deg^2 to mm^2 for a given eccentricity
%
% Syntax:
%   WatsonRGCCalc = WatsonRGCModel();
%   eccDegs = 0;
%   areaMM2 = 1.0;
%   areaDeg2 = WatsonRGCCalc.degSquaredToMMSquared(areaMM2, eccDegs);
%
% Description:
%   Method to convert a retinal area specified in mm^2 to retinal 
%   area specified in deg^2 squared, for a given eccentricity
%
% Inputs:
%    obj                       - The WatsonRGCModel object
%    mmSquared                 - Retinal area, specified in mm^2
%    eccDegs                   - Retinal eccentricity, specified in degs
%
% Outputs:
%    val                       - Retinal area, specified in deg^2
%
% References:
%    Watson (2014). 'A formula for human RGC receptive field density as
%    a function of visual field location', JOV (2014), 14(7), 1-17.
%
% History:
%    11/8/19  NPC, ISETBIO Team     Wrote it.
    

    % Compute mmSquaredPerDegSquared conversion factor for the given eccentricity
    mmSquaredPerDegSquared = obj.alpha(eccDegs);
    % Return corresponding area in deg^2
    val = 1/mmSquaredPerDegSquared * mmSquared;
end