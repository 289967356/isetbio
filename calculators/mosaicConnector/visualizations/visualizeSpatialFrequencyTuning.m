function visualizeSpatialFrequencyTuning(axesHandle, spatialFrequenciesCPD, theSFtuning, theSFtuningSE, maxSpikeRateModulation, ...
    spatialFrequenciesCPDHR, responseTuningHR, modelParams, targetRGC, LMScontrast, exportFig, exportDir)

    % Reset figure
    if (isempty(axesHandle))
        % Set plotLab
        figSize = [7 7];
        plotlabOBJ = setupPlotLab(0, figSize);
        hFig = figure(334); clf;
        axesHandle = axes('Position', [0.12*figSize(1) 0.12*figSize(2) 0.85*figSize(1) 0.8*figSize(2)]);
    else
        exportFig = false;
    end
    
    % Plot the error of the mean vertical bars
    for k = 1:numel(spatialFrequenciesCPD)
        line(axesHandle, spatialFrequenciesCPD(k)*[1 1], theSFtuning(k)+theSFtuningSE(k)*[-1 1], 'LineWidth', 1.5, 'Color', [0.3 0.3 0.3]); hold on;
    end
            
    % Plot the mean points
    scatter(axesHandle, spatialFrequenciesCPD, theSFtuning, 'MarkerEdgeColor', [0.3 0.3 0.3], 'MarkerFaceColor', [0.8 0.8 0.8]);
    
    % Plot the model fit
    line(axesHandle, spatialFrequenciesCPDHR, responseTuningHR, 'Color', [1 0 0]);
            
    % Set the axes
    axis(axesHandle, 'square');
    set(axesHandle, 'XScale', 'log', 'XLim', [0.03 101], 'XTick', [0.03 0.1 0.3 1 3 10 30], ...
        'YTick', [0:5:200], 'YScale', 'linear','YLim', [0 maxSpikeRateModulation]);
    xlabel(axesHandle,'spatial frequency (c/deg)');
    ylabel(axesHandle, 'response modulation');
            
    title(axesHandle,sprintf('RGC #%d,  c_{LMS} = (%0.1f, %0.1f, %0.1f)', targetRGC, LMScontrast(1), LMScontrast(2), LMScontrast(3)));
    
    % Show the params of the fitted model
    if (~isempty(modelParams))
        text(axesHandle, 0.035, maxSpikeRateModulation*0.82, sprintf('K_c: %2.0f\nK_s: %2.0f\nR_c: %2.1f arcmin\nR_s: %2.1f arcmin', ...
            modelParams.kC, modelParams.kS, modelParams.rC*60, modelParams.rS*60), 'FontSize', 12, 'FontName', 'Source Code Pro');
    end
    
    drawnow;
    
    if (exportFig)
        plotlabOBJ.exportFig(hFig, 'pdf', sprintf('SF_RGC_%d_LMS_%0.2f_%0.2f_%0.2f',targetRGC, LMScontrast(1), LMScontrast(2), LMScontrast(3)), exportDir);
        setupPlotLab(-1);
    end
end

function plotlabOBJ = setupPlotLab(mode, figSize)
    if (mode == 0)
        plotlabOBJ = plotlab();
        plotlabOBJ.applyRecipe(...
                'colorOrder', [0 0 0; 1 0 0], ...
                'axesBox', 'off', ...
                'axesTickDir', 'both', ...
                'renderer', 'painters', ...
                'lineMarkerSize', 14, ...
                'axesTickLength', [0.01 0.01], ...
                'legendLocation', 'SouthWest', ...
                'figureWidthInches', figSize(1), ...
                'figureHeightInches', figSize(2));
    else
        plotlab.resetAllDefaults();
    end
end 