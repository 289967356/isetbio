function y = sumoftwodblexponentials(coef, x)
% Compute sum of two double exponential functions, with no mean offset.
%
% Syntax:
%   y = sumoftwodblexponential(coef, x)
%
% Description:
%    Compute sum of two double exponential functions, with no mean offset.
%       y = A1 * exp(-C1 * abs(x)) + A2 * exp(-C2 * abs(x));
%
% Inputs:
%    coef - A vector containing the required four coefficients in the order
%           described below:
%               1 - A1 - Variable to multiply the first exponent by
%               2 - C1 - The negative is multipled by the absolute value of
%                        x and then the exponent thereof is calculated
%               3 - A2 - Variable to multiply the second exponent by
%               4 - C2 - The negative is multiplied by the absolute value
%                        of x and then the exponent thereof is calculated
%    x    - The only variable to repeat in the calculations, the absolute
%           value of this variable will be used in both mini-functions
%
% Outputs:
%    y    - The calculated sum of the double exponential functions.
%

% History:
%    01/08/16  dhb  Added commments
%              dhb  Changed name and what is computed to be more standard
%    12/04/17  jnm  Formatting

% Do it
y = coef(1) .* exp(-coef(2) * abs(x)) + coef(3) .* exp(-coef(4) * abs(x));
