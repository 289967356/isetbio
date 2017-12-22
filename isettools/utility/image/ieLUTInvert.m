function lut = ieLUTInvert(inLUT, nSteps)
% Calculate inverse lookup table (lut) at certain sampling steps
%
% Syntax:
%   lut = ieLUTInvert(inLUT, nSteps)
%
% Description:
%    Calculate inverse lookup table (lut) at certain sampling steps
%
% Inputs:
%    inLUT  - The gamma table that converts linear DAC values to RGB
%             settings. The number of rows of this table is taken as the
%             number of available digital output levels.
%    nSteps - (Optional) The sampling steps, the returned gamma table is
%             sampled at the number of points specified by nSteps.
%             Default is 2048.
%
% Outputs:
%    lut    - The returned lookup table.
%
% See Also:
%   ieLUTDigital, ieLUTLinear
%

% History:
%    xx/xx/13       (c) Imageval Consulting, LLC 2013
%    01/07/15  dhb  Changed convention for passed resolution to be the
%                   number of samples (nSteps) in the returned table.
%    04/02/15  dhb  Pull clipping out of loop (cleaner) and clip at the
%                   correct level (which was wrong).
%    12/06/17  jnm  Formatting

% Examples:
%{
    d = displayCreate('CRT-HP');
    inLUT = displayGet(d, 'gamma');
    lut = ieLUTInvert(inLUT, 2048);
    vcNewGraphWin;
    plot(lut)
%}

%% Check inputs
if notDefined('inLUT'), error('input lut required'); end
if notDefined('nSteps'), nSteps = 2048; end

%% Computes inverse gamma table
%  Loop over primaries
nInSteps = size(inLUT, 1);
y = 1 : nInSteps;
iY = linspace(0, (nSteps - 1) / nSteps, nSteps);
lut = zeros(length(iY), size(inLUT, 2));
for ii = 1 : size(inLUT, 2)
    % sort inLUT, theoretically, inLUT should be monochrome increasing, but
    % sometimes, the intensity at very low light levels cannot be measured
    % and we just set all of them to 0
    [x, indx] = unique(inLUT(:, ii));
    lut(:, ii) = interp1(x, y(indx), iY(:), 'pchip');
    
    % Handle extrapolation values
    % ieClip can handle this if black is black for the display. Otherwise, 
    % we need to handle extrapolation independently
    lut(iY < min(x), ii) = 0;
    lut(iY > max(x), ii) = nInSteps;
end

% Clip the output to the max possible value. We take this as the maximum
% of the input steps.
lut = ieClip(lut, 0, max(y));

end