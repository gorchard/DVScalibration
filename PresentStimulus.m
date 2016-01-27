function [dX, dY] = PresentStimulus(num_rectangles, num_flashes)
% [dX, dY] = PresentStimulus(num_rectangles, num_flashes)
% Creates and presents a checkerboard calibration pattern on the screen.
%
% TAKES IN:
% 'num_rectangles' = [num_rectanglesX; num_rectanglesY]
% A 2x1 vector containing the number of rectangles to display
% in the horizontal and vertical directions respectively. If only a scalar
% is passed, the same number of rectangles will be shown in each direction.
%
% 'num_flashes'
% Dictates how many times the stimulus will be flashed on the
% screen. A negative or zero value creates a static stimulus (if non-DVS
% calibration is to be used). If this paramter is omitted,
% 'num_flashes = 0' is assumed (useful for ATIS or DAVIS calibration using
% snapshot/APS functionality instead of DVS).
%
%
% RETURNS:
% [dX, dY]
% The horizontal (dX) and vertical (dY) size of the rectangles displayed
% on the screen, in units of millimeters. This parameter is required for
% calibration using the Caltech Camera Calibration Toolbox available from:
% http://www.vision.caltech.edu/bouguetj/calib_doc/index.html
% (to make sure the X and Y directions used by the calibration toolbox are
% the same as used by this function, always start from the lower left
% corner when outlining the grid pattern during calibration).
%
%
% EXAMPLE USE:
% [dY, dX] = PresentStimulus([10,10], 0); %display static image
% [dY, dX] = PresentStimulus(10, 0); %display static image, identical to above command
% [dY, dX] = PresentStimulus([10,10], 10); %flash ten times
%
% written by Garrick Orchard - June 2015
% garrickorchard@gmail.com

close all;
figure(1)
%% check inputs
%if only one value was passed for num_rectangles, show the same number in
%each dimension
if length(num_rectangles)<2
    num_rectangles = [num_rectangles,num_rectangles];
end

% check if the 'num_flashes' variable was passed
if ~exist('num_flashes', 'var')
    num_flashes = 0;
end

%% Obtains the screen size information and use it to determine the rectangle size
[Screen_size_pixels, Screen_size_mm] = getScreenMeasurements();

%fixed parameters of the setup
figure_borderSize = 150; %leave space of 150 pixels on each side of the axes for the figure controls etc
image_borderSize = 10; %within the image, create a border of size 10 pixels to ensure contrast with the outside rectangles

%How big is each rectangle in units of pixels?
rectangleSize_pixels = floor((Screen_size_pixels - 2*(figure_borderSize+image_borderSize))./num_rectangles);

%How big is each rectangle in units of millimeters?
rectangleSize_mm = Screen_size_mm.*rectangleSize_pixels./Screen_size_pixels;

%How big is the checkered part of the image
image_inner_dim = num_rectangles.*rectangleSize_pixels; % the dimenstion of the inside of the image (not including the border)

%Create a black image to fit both the checkerboard and the image border
imgTemplate = zeros(image_inner_dim+2*image_borderSize);

%% create the checkerboard image
img = imgTemplate;
for x = 1:num_rectangles(1)
    for y = (1+rem(x+1,2)):2:num_rectangles(2)
        xloc = image_borderSize + ((1+(x-1)*rectangleSize_pixels(1)):(x*rectangleSize_pixels(1)));
        yloc = image_borderSize + ((1+(y-1)*rectangleSize_pixels(2)):(y*rectangleSize_pixels(2)));
        img(xloc,yloc) = 1;
    end
end

%% display
imshow(img');

warning('Do not resize the checkerboard image window! It has been shown on the screen at a known size which must be known for calibration')
disp('Checkerboard rectangle size is:')
disp(['Vertical: ', num2str(rectangleSize_mm(2)), 'mm'])
disp(['Horizontal: ', num2str(rectangleSize_mm(1)), 'mm'])

warning('The calibration toolbox X and Y axes depend on which corner of the checkerboard is clicked first when extracting corners. To match convention of this function, always start at the bottom left corner when extracting corners during calibration.')

if num_flashes>1
    input('Press any button to begin flashing...\n');
    figure(1) %bring the figure to the front (if it is not already in front)
    pause(1) %small pause
    
    % flash 'num_flashes' times
    for i = 1:num_flashes
        imshow(imgTemplate')
        drawnow;
        imshow(img')
        drawnow;
    end
end

dX = rectangleSize_mm(1);
dY = rectangleSize_mm(2);