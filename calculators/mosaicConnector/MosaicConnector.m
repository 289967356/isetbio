function MosaicConnector

    rootDir = fileparts(which(mfilename()));
    tmpDir = fullfile(rootDir, 'tmpMatFiles');
    exportsDir = fullfile(rootDir, 'exports');
    
    doInitialMosaicCropping = ~true;                    % phase 1 - crop within circular window
    checkMosaicSeparationAndCropAgain = ~true;          % phase 2 - check separation and possibly crop within rectangular window
    assignConeTypes = ~true;                            % phase 3 - assign cone types
    connectConesToRGCcenters = ~true;                   % phase 4 - connect cones to RGC RF centers
    visualizeConeToRGCcenterConnections = true;         % phase 5 - visualize cone inputs to RGC RF centers
    connectConesToRGCsurrounds = true;                  % phase 6 - connect cones to RGC RF surrounds
    coVisualizeRFsizeWithDendriticFieldSize = ~true;    % Phase 10
    
    % Configure the phase run parameters
    connector = containers.Map();
    
    % Medium-size mosaic
    inputMosaic = struct('fov',20, 'eccSamples', 256);
    
    % Large mosaic
    inputMosaic = struct('fov',40, 'eccSamples', 482);
    
    % Phase1: isolate the central (roiRadiusDeg) mosaic
    connector('phase1') = struct( ...
        'run', doInitialMosaicCropping, ...
        'runFunction', @runPhase1, ...
        'whichEye', 'right', ...                // input mosaic params
        'mosaicFOVDegs', inputMosaic.fov, ...                // input mosaic params
        'eccentricitySamplesNumCones', inputMosaic.eccSamples, ... // input mosaic params
        'eccentricitySamplesNumRGC', inputMosaic.eccSamples, ...   // input mosaic params
        'roiRadiusDeg', Inf, ...                 // processing params
        'outputFile','roiMosaic', ...
        'outputDir', tmpDir ...
    );
        
    % Phase 2: Check that rfs are not less than a treshold (x mean spacing). If any rfs
    % are found with a separation less than that, an error is thrown. Also
    % crop to desired size
    roiCropDegs = struct('xo', 0.0, 'yo', 0.0, 'width', 45, 'height',24);
    postFix = sprintf('eccX_%2.1f_eccWidth_%2.1f_eccHeight_%2.1f', roiCropDegs.xo, roiCropDegs.width, roiCropDegs.height);
    
    connector('phase2') = struct( ...
        'run', checkMosaicSeparationAndCropAgain, ...
        'runFunction', @runPhase2, ...
        'inputFile', connector('phase1').outputFile, ...
        'roiRectDegs', roiCropDegs, ...                                 // cropped region to include
        'thresholdFractionForMosaicIncosistencyCorrection', 0.6, ...    // separation threshold for error
        'outputFile', sprintf('%s__CheckedStats', sprintf('%s_%s',connector('phase1').outputFile, postFix)),...
        'outputDir', tmpDir ...
    );

    % Phase 3: Assign cone types to the coneMosaic
    connector('phase3') = struct( ...
        'run', assignConeTypes, ...
        'runFunction', @runPhase3, ...
        'inputFile', connector('phase2').outputFile, ...
        'tritanopicAreaDiameterMicrons', 2.0*1000*WatsonRGCModel.rhoDegsToMMs(0.3/2), ...        // Tritanopic region size: 0.3 deg diam
        'relativeSconeSpacing', 2.7, ...                        // This results to around 8-9% S-cones
        'LtoMratio', 2.0, ...                                   // Valid range: [0 - Inf]
        'outputFile', sprintf('%s__ConesAssigned', connector('phase2').outputFile),...
        'outputDir', tmpDir ...
    );

    % Phase 4: Connect cones to the mRGC RF centers
    connector('phase4') = struct( ...
        'run', connectConesToRGCcenters, ...
        'runFunction', @runPhase4, ...
        'inputFile', connector('phase3').outputFile, ...
        'orphanRGCpolicy', 'remove', ...                        // How to deal with RGCs that have no input
        'outputFile', sprintf('%s__ConeConnectionsToRGCcenters', connector('phase3').outputFile),...
        'outputDir', tmpDir ...
    );


    % Phase 5: Visualize connections at a target patch
    patchEccDegs = [23 0]/10;
    patchSizeDegs = [1 1]/2;
    connector('phase5') = struct( ...
        'run', visualizeConeToRGCcenterConnections, ...
        'runFunction', @runPhase5, ...
        'inputFile', connector('phase4').outputFile, ...
        'zLevels', [0.3 1], ...                                     // contour levels
        'whichLevelsToContour', [1], ...                            // Which level to plot the isoresponse contour
        'displayEllipseInsteadOfContour', ~true, ...                // Ellipse fitted to the sum of flat-top gaussians
        'patchEccDegs', patchEccDegs, ...                           // Eccenticity of visualized patch
        'patchSizeDegs', patchSizeDegs, ...                         // Size of visualized patch
        'outputFile', sprintf('%s__Visualization', connector('phase4').outputFile),...
        'exportsDir', exportsDir, ...
        'outputDir', tmpDir ...
    );
        
    % Phase 6: Compute cone inputs to mRGC RF surrounds
    connector('phase6') = struct( ...
        'run', connectConesToRGCsurrounds, ...
        'runFunction', @runPhase6, ...
        'inputFile', connector('phase4').outputFile, ...
        'zLevels', [0.3 1], ...                                     // contour levels
        'whichLevelsToContour', [1], ...                            // Which level to fit the ellipse to
        'patchEccDegs', [12 0], ...                                 // Eccenticity of visualized patch
        'patchSizeDegs', [2 2], ... 
        'outputFile', sprintf('%s__Visualization2', connector('phase4').outputFile),...
        'exportsDir', exportsDir, ...
        'outputDir', tmpDir ...
    );

    % Phase 10: Visualize relationship between RF sizes and dendritic size data
    connector('phase10') = struct( ...
        'run', coVisualizeRFsizeWithDendriticFieldSize, ...
        'runFunction', @runPhase10, ...
        'inputFile', connector('phase4').outputFile, ...
        'zLevels', [0.3 1], ...                                     // contour levels
        'whichLevelsToContour', [1], ...                            // Which level to fit the ellipse to
        'patchEccDegs', [12 0], ...                                 // Eccenticity of visualized patch
        'patchSizeDegs', [2 2], ... 
        'outputFile', sprintf('%s__Visualization2', connector('phase4').outputFile),...
        'exportsDir', exportsDir, ...
        'outputDir', tmpDir ...
    );

    runPhases = keys(connector);
    for k = 1:numel(runPhases) 
        theRunPhase = runPhases{k};
        if (connector(theRunPhase).run)
            runParams = connector(theRunPhase);
            runFunction = connector(theRunPhase).runFunction;
            runFunction(runParams);
            return;
        end
    end  
    
end