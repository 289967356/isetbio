function checkConnectionMatrix(connectionMatrix, coneTypes, conePositionsMicrons, targetConeIndex, prefix)
    global SCONE_ID 
    % Check that targetCone (L- or M-) is connected to one and only one RGC
    if (coneTypes(targetConeIndex) ~= SCONE_ID)
        rgcNumsConnectingTo(targetConeIndex) = full(sum(connectionMatrix(targetConeIndex,:),2));
        if (rgcNumsConnectingTo(targetConeIndex) ~= 1)
            fprintf('%s: cone at %2.0f, %2.0f projects to %d RGCs\n', prefix, conePositionsMicrons(targetConeIndex,1), conePositionsMicrons(targetConeIndex,2), rgcNumsConnectingTo);
        end
    end

end
