function visualizeRFs(connectivityMatrix, conePositionsMicrons, RGCRFPositionsMicrons, coneSpacingsMicrons, roi)

    % Sampling for contours
    deltaX = 0.2;
    xAxis = (roi.center(1)-roi.size(1)/2): deltaX: (roi.center(1)+roi.size(1)/2);
    yAxis = (roi.center(2)-roi.size(2)/2): deltaX: (roi.center(2)+roi.size(2)/2);
    [X,Y] = meshgrid(xAxis,yAxis);
    
   
    zLevels = [0.05 1 ];
    
    whichLevelsToContour = [1];
    
    hFig = figure(99); clf;
    theAxesGrid = plotlab.axesGrid(hFig, ...
            'leftMargin', 0.03, ...
            'bottomMargin', 0.05, ...
            'rightMargin', 0.03, ...
            'topMargin', 0.03);
        
    theAxesGrid = theAxesGrid{1,1};
    set(theAxesGrid, 'XLim', roi.center(1)+roi.size(1)/2*[-1 1], 'YLim', roi.center(2)+roi.size(2)/2*[-1 1]);
    hold(theAxesGrid, 'on');
    
    rgcsNum = size(RGCRFPositionsMicrons,1);
    for RGCindex = 1:rgcsNum
        
        connectivityVector = squeeze(connectivityMatrix(:, RGCindex));
        
        % Generate RFs of RGCs based on cone positions and connection matrix
        theRF = generateRGCRFsFromConnectivityMatrix(...
            connectivityVector, conePositionsMicrons, coneSpacingsMicrons, X,Y);

        C = contourc(xAxis, yAxis,theRF, zLevels);
        renderContourPlot(theAxesGrid, C, zLevels, whichLevelsToContour);
        
        showConnectedConePolygon = true;
        if (showConnectedConePolygon)
            % Connected cones
            indicesOfConeInputs = find(connectivityVector>0);
            displayConnectedConesPolygon(indicesOfConeInputs, conePositionsMicrons);
        end
        
    end
        
    % Cones in blue
    scatter(conePositionsMicrons(:,1), conePositionsMicrons(:,2), 'b');
    for k = 1:size(conePositionsMicrons,1)
        text(conePositionsMicrons(k,1)+0.5, conePositionsMicrons(k,2)+1, sprintf('%d', k), 'Color', 'b');
    end
     
    colormap(brewermap(512, 'greys'))
    set(theAxesGrid, 'CLim', [0 1]);
end

function renderContourPlot(theAxes, C, zLevels, whichLevelsToContour )
    k = 1;
    contoursNum = 0;
    while k < size(C,2)
        level = C(1,k);
        points = C(2,k);
        if (level == zLevels(whichLevelsToContour(1)))
            edgeAlpha = 0.7;
            faceAlpha = 0.2;
        elseif (ismember(level, zLevels(whichLevelsToContour)))
            edgeAlpha = 0;
            faceAlpha = 0.2+(level)*0.05;
        else
            % skip this contour
            k = k+points+1;
            continue;
        end
        
        xRGCEnsembleOutline = C(1,k+(1:points));
        yRGCEnsembleOutline = C(2,k+(1:points));
        v = [xRGCEnsembleOutline(:) yRGCEnsembleOutline(:)];
        f = 1:numel(xRGCEnsembleOutline);
        patch(theAxes, 'Faces', f, 'Vertices', v, 'FaceColor', [0.5 0.5 0.5]-level*0.05, ...
            'FaceAlpha', faceAlpha, 'EdgeColor', [0.2 0.2 0.2], 'EdgeAlpha', edgeAlpha, 'LineWidth', 1.0);
        
        k = k+points+1;
        contoursNum = contoursNum + 1;
    end
end


function theRF = generateRGCRFsFromConnectivityMatrix(connectivityVectorForRGC, conePositions, coneSpacings,  X,Y)
    
    theRF = [];
    connectedConeIDs = find(connectivityVectorForRGC>0);
    flatTopZ = 0.05;
    
    for k = 1:numel(connectedConeIDs)
        coneIndex = connectedConeIDs(k);
        cP = squeeze(conePositions(coneIndex,:));
        coneSigma = coneSpacings(coneIndex)/6;
        coneProfile = exp(-0.5*((X-cP(1))/coneSigma).^2) .* exp(-0.5*((Y-cP(2))/coneSigma).^2);
        coneProfile(coneProfile>=flatTopZ) = flatTopZ;
        if (isempty(theRF))
            theRF = coneProfile * connectivityVectorForRGC(coneIndex);
        else
            theRF = theRF + coneProfile * connectivityVectorForRGC(coneIndex);
        end 
    end
    theRF = theRF/max(theRF(:));
        
end

function displayConnectedConesPolygon(indicesOfConeInputs, conePositionsMicrons)
    % Polygon connecting input cones
    xx = conePositionsMicrons(indicesOfConeInputs,1);
    yy = conePositionsMicrons(indicesOfConeInputs,2);
    xo = mean(xx);
    yo = mean(yy);
    dx = xx-xo;
    dy = yy-yo;
    [~,idx] = sort(unwrap(atan2(dy,dx)));
    xx = xx(idx);
    yy = yy(idx);
    xx(end+1) = xx(1);
    yy(end+1) = yy(1);
    plot(xx,yy, 'k--', 'LineWidth', 1.0);
end




