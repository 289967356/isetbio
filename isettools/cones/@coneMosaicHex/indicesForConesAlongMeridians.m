function [idxOfConesAlongHorizMeridian, idxOfConesAlongVertMeridian, ...
    eccDegsOfConesAlongHorizMeridian, eccDegsOfConesAlongVertMeridian] = ...
    indicesForConesAlongMeridians(obj)
% Return the indices for all cones along the meridians
%
% Syntax:
%   [idxOfConesAlongHorizMeridian, idxOfConesAlongVertMeridian] = ...
%       indicesForConesAlongMeridians(obj)
%
% Description:
%    Return the indices for for all cones along the meridians
%
% Inputs:
%    obj        - The cone mosaic hex object
%
% Outputs:
%    idxOfConesAlongHorizMeridian - indices of cones along the horizontal meridian
%    idxOfConesAlongVertMeridian - indices of cones along the vertical meridian
%
% Optional key/value pairs:
%    None.
%

% History:
%    12/7/18  NPC  ISETBIO TEAM, 2018

    xSupport = squeeze(obj.patternSupport(1, :, 1));
    ySupport = squeeze(obj.patternSupport(:, 1, 2));
    
    idx = find(obj.pattern > 1);
    [iRows, iCols] = ind2sub(size(obj.pattern), idx); 
    
    coneXcoords = (xSupport(iCols))';
    coneYcoords = ySupport(iRows);
    coneDiameter = diameterForCircularApertureFromWidthForSquareAperture(obj.pigment.width);
    idxOfConesAlongHorizMeridian = find(abs(coneYcoords) < coneDiameter);
    idxOfConesAlongVertMeridian = find(abs(coneXcoords) < coneDiameter);
    
    metersToDegs = 1e6 / obj.micronsPerDegree;
    eccDegsOfConesAlongHorizMeridian = metersToDegs*coneXcoords(idxOfConesAlongHorizMeridian);
    eccDegsOfConesAlongVertMeridian = metersToDegs*coneYcoords(idxOfConesAlongVertMeridian);
    
    idxOfConesAlongHorizMeridian = idx(idxOfConesAlongHorizMeridian);
    idxOfConesAlongVertMeridian = idx(idxOfConesAlongVertMeridian);
end

