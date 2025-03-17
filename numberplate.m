clc; clear; close all;

% Prompt user to select an image
[file, path] = uigetfile({'*.jpg;*.png;*.jpeg', 'Image Files'}, 'Select an Image');
if isequal(file, 0)
    disp('No file selected.');
    return;
end

% Read and display the input image
img = imread(fullfile(path, file));
figure, imshow(img), title('Original Image');

% Convert to grayscale
gray_img = rgb2gray(img);

% Apply edge detection
edges = edge(gray_img, 'Canny');

% Morphological operations to enhance number plate region
se = strel('rectangle', [5 5]); % Structuring element
dilated_img = imdilate(edges, se);

% Find connected components
stats = regionprops(dilated_img, 'BoundingBox', 'Area');

% Initialize empty variable for plate region
plate_region = [];

% Loop through detected components
for i = 1:length(stats)
    bbox = stats(i).BoundingBox;
    width = bbox(3);
    height = bbox(4);
    
    % Adaptive aspect ratio filtering (plates are usually wider)
    aspect_ratio = width / height;
    if aspect_ratio > 2 && aspect_ratio < 6 % Generalized range
        plate_region = imcrop(gray_img, bbox);
        figure, imshow(plate_region), title('Extracted Number Plate');
        break;
    end
end

% Perform OCR if plate region is detected
if ~isempty(plate_region)
    plate_text = ocr(plate_region, 'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');
    disp(['Detected Plate Number: ', strtrim(plate_text.Text)]);
else
    disp('Number plate not detected.');
end
