% Image Signal Analysis (Parts 3 & 4)

close all;

function filterImage(fileName)
    %%% PRE-PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Importing
    filepath = "Data/Images/";
    I = imread(filepath + fileName + ".jpg");
    
    % Convert to grayscale
    Igray = rgb2gray(I);
    Igray_norm = im2double(Igray);
    
    % Threshold bright regions
    brightThreshold = 0.84; 
    brightMask = Igray_norm > brightThreshold;
    
    % Stretch constrast
    scaleFactor = 0.5;

    Ilog = Igray_norm;
    Ilog(brightMask) = log(1 + Igray_norm(brightMask));

    Ilog(brightMask) = Ilog(brightMask) * scaleFactor;
    Ilog = mat2gray(Ilog);

    Icontrast = imadjust(Ilog); 
    
    % Smoothen 
    Ismoothed = imgaussfilt(Icontrast, 2);
    
    % Binarize
    level = 0.35;
    Ithresh = imbinarize(Ismoothed, level); 
    % figure, imshow(Ithresh), title('Binarized Image');
    
    % Remove small objects (specks)
    Ithresh_cleaned = bwareaopen(Ithresh, 3); % Remove < 3 pixels
    Ithresh_complemented = imcomplement(Ithresh_cleaned);
    
    % Morphologically close/seal gaps
    se = strel('disk', 2);
    Iclosed = imclose(Ithresh_complemented, se);
    
    % Fill holes
    binaryMask = imfill(Iclosed, 'holes');
    
    %%% WASHER SEGMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Obtain circle attributes
    [centers, radii, ~] = imfindcircles( ...
        binaryMask,[80 250], ...
        'Sensitivity', 0.90);
    
    % Mark circles
    mask = false(size(binaryMask));
    for i = 1:length(radii)

        [xGrid,yGrid] = meshgrid(1:size(binaryMask, 2), ...
            1:size(binaryMask, 1));

        mask = mask | ( ...
            (xGrid - centers(i, 1)).^2 + ...
            (yGrid - centers(i, 2)).^2 <= radii(i)^2);
    end
    
    se = strel('disk', 8); % Structural element for dilation
    mask = imdilate(mask, se); % Expand the mask region
    
    % Set the masked regions to black
    binaryMask(mask) = 0; 
    
    %%% WATERSHED SCREW SEGMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Distance transform
    D = 255-uint8(bwdist(~binaryMask));

    % First Watershed
    W1 = watershed(D);
    
    % Overlay Ridge-lines on Binary Image
    bmOverlayed = binaryMask;
    bmOverlayed(W1 == 0) = 0;
    
    % Suppress Minima Below Threshold
    bWMask = imextendedmin(D,5);

    % Distance transform Based on Suppressed Minima
    D2 = imimposemin(D,bWMask);

    % Second Watershed
    W2 = watershed(D2);
   
    % Overlay Ridge-lines on Binary Image
    bmOverlayed2 = binaryMask;
    bmOverlayed2(W2 == 0) = 0;
    
    % Overlay Segmented Images onto Original Greyscale
    figure, 
    imshow(labeloverlay( ...
    Igray_norm,double(bmOverlayed2),'Colormap',[1 1 1],'Transparency', 0)),
    title("Original Image Overlay (Final)")
    
    
    %%% OBJECT CLASSIFICAION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Count the total number of objects (not including background)
    stats = regionprops(bmOverlayed2, 'Area', 'Perimeter', ...
        'MajorAxisLength', 'MinorAxisLength', 'BoundingBox');
    
    % Initialize counters
    numSmallScrews = 0;
    numLargeScrews = 0;
    
    % Classify Each Object
    for i = 1:length(stats)
        % Extract region properties
        area = stats(i).Area;
        boundingBox = stats(i).BoundingBox;
    
        % disp("Area " + area);
            
        if area >= 3000 && area < 18000
            % Small Screw
            numSmallScrews = numSmallScrews + 1;
            rectangle('Position', boundingBox, 'EdgeColor', ...
                'y', 'LineWidth', 2);
    
        elseif area >= 18000
            % Large Screw
            numLargeScrews = numLargeScrews + 1;
            rectangle('Position', boundingBox, 'EdgeColor', ...
                'b', 'LineWidth', 2);
        end

    end
    
    % Overlay washers
    for i = 1:length(radii)
        viscircles(centers(i, :), radii(i), ...
            'EdgeColor', 'g', 'LineWidth', 2);
    end
    
    % Print counts
    disp(fileName +" Object Counts: ");
    disp(['Number of Washers: ', num2str(length(radii))]);
    disp(['Number of Small Screws: ', num2str(numSmallScrews)]);
    disp(['Number of Large Screws: ', num2str(numLargeScrews)]);
    disp(['Total number of segmented objects: ', num2str( ...
        size(centers,1) + numSmallScrews + numLargeScrews)]);
end

filterImage("Easy");
filterImage("Medium");
filterImage("Hard");
filterImage("Very_Hard");
filterImage("Extreme");
