function bool = checkfields(s, varargin)
% Check for the presence of a field, possibly nested, in a structure
%
% Syntax:
%   bool = checkfields(s, varargin)
%
% Description:
%    We often check for a field that is nested within other fields within a
%    structure. We have been doing this with a series of nested or grouped
%    isfield statements. This got annoying, so I wrote this routine as a
%    replacement. It extends the functionality of 'isfield'.
%
%    Suppose there is a structure, pixel.OP.pd.type; You can verify that
%    the sequence of nested structures is present via the call
%
%      checkfields(pixel, 'OP', 'pd', 'type')
%
% Inputs:
%    s        - The structure to examine
%    varargin - (Optional) A variable length of arguments to check the
%               structure for (in the specified order)
%
% Outputs:
%    bool     - The boolean indicating whether or not the field(s) are
%               present in the provided structure. 1 Is True (field
%               sequence is present), and 0 is False (absent). 
%
% Notes:
%    * [Note: JNM - This requires the sequence to be in order, and from the
%      beginning. See Example below for clarification.]

% History:
%    xx/xx/03       Copyright ImagEval Consultants, LLC, 2003.
%    12/12/17  jnm  Formatting

% Examples:
%{
    pixel.OP.pd.type = "rgb"
    % True
    checkfields(pixel, 'OP', 'pd', 'type')
    checkfields(pixel, 'OP', 'pd')
    checkfields(pixel, 'OP')
    checkfields(pixel)

    % False (even though the fields are present in our structure)
    checkfields(pixel, 'pd')
    checkfields(pixel, 'OP', 'type')
    checkfields(pixel, 'pd', 'type')
    checkfields(pixel, 'type')
%}

bool = 1;
tst = s;

for ii = 1 : length(varargin)
    if isfield(tst, varargin{ii})
        tst = tst.(varargin{ii});
    else
        bool = 0;
        break;
    end
end

end