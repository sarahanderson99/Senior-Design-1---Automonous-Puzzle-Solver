%Group 13 Project 2 Code

close all
clc
clear

% Setting up webcam properties
cam_list = webcamlist;
cam_name = cam_list{2};
cam = webcam(cam_name);
%% 
preview(cam)
%% 
closePreview(cam)
%% For the markers image
img = snapshot(cam);
figure()
imshow(img)
%% 
preview(cam)
%% 
closePreview(cam)
%% 
img2 = snapshot(cam);
figure()
imshow(img2)
%%
imwrite(img, 'markers_test.png')
imwrite(img2, 'gameboard_test.png')
%% START HERE IF ALREADY HAVE IMAGES
%Create our structure for housing all data
gameState = struct;

%Read in both images
Image_Background = imread('gameboard_test.png');
Image_Markers = imread('markers_test.png');

[Binary_Image, STATS] = img2binary(Image_Background, Image_Markers);
%Store centroid Locations
gameState.centroid_locations = centroid_finder(STATS);
%Finds the RGB values associated with each centroid
gameState.rgb_centroid_values = rgb_finder(gameState.centroid_locations, Image_Markers);
%Finds the Color of each shape
gameState.centroid_colors = color_finder(gameState.rgb_centroid_values);
%Determines the angle of each centroid
gameState.centroid_angles = angle_finder(gameState.centroid_locations);
%Plot the original image, its centroid, location, and color
plot_centroids(Image_Markers, gameState.centroid_locations, gameState.centroid_colors);

function [Binary, STATS] = img2binary(Background, Markers)
    [height,width,depth] = size(Background);
    [height_m,width_m,depth_m] = size(Markers);
    Image_BackgroundSub = Background - Markers;
    figure();
    imshow(Image_BackgroundSub)

    
    % Compute Binary Image for imageprops
     Image_BackgroundSub2 = Image_BackgroundSub;
    for i=1:height
        for j=1:width
            if (Image_BackgroundSub(i,j,1) > 50) || ...
               (Image_BackgroundSub(i,j,2) > 50) || ...
               (Image_BackgroundSub(i,j,3) > 50)
                %Will Show in Green
                Image_BackgroundSub2(i,j,:) = [175,200,175];
            end
        end
    end

    %Convert subtracted image to binary
    Binary_1 = im2bw(Image_BackgroundSub2);

    SE = strel('disk',5);
    Binary = imerode(Binary_1, SE);
    figure();
    imshow(Binary);
    title('Binary Image Erosion');
    % Stores data on centroids
    STATS = regionprops(Binary, 'centroid');
end
 

function centroid_locations = centroid_finder(STATS)
    %Finds Centroid Values for each shape
    items = size(STATS);
    stored_values = {};
    centroid_locations = [];
    for i = 1:items
        y_temp = STATS(i).Centroid(1);
        x_temp = STATS(i).Centroid(2);

        %Stores locations of each centroid
        if x_temp >= 640
            x_temp = 0;
            y_temp = 0;
        end
        temp = [x_temp, y_temp];
        centroid_locations = [centroid_locations; temp];
    end
end


function rgb_centroid_values = rgb_finder(centroid_locations, Image_Markers)
    %Determine the RGB values associated with each 3x3 around the centroid
    items = size(centroid_locations);
    rgb_centroid_values = [];
    for i = 1:items(1)
        x_temp = round(centroid_locations(i,1));
        y_temp = round(centroid_locations(i,2));

        r_sum = 0;
        g_sum = 0;
        b_sum = 0;
        
        %Double for loop to average 9 different pixel values
        for j = -1:1
            for g = -1:1
                %Looks for RGB values associated with each centroid. (y,x)
                r_temp = int16(Image_Markers(round(x_temp) + j, round(y_temp) + g, 1));
                g_temp = int16(Image_Markers(round(x_temp) + j, round(y_temp) + g, 2));
                b_temp = int16(Image_Markers(round(x_temp) + j, round(y_temp) + g, 3));
                r_sum = r_sum + int16(r_temp);
                g_sum = g_sum + int16(g_temp);
                b_sum = b_sum + int16(b_temp);
            end
            if j==1 && g==1
                r_temp = r_sum / 9;
                g_temp = g_sum / 9;
                b_temp = b_sum / 9;
            end
        end
        temp_rgb = [r_temp, g_temp, b_temp];
        rgb_centroid_values = [rgb_centroid_values; temp_rgb];
    end
end

function colors = color_finder(rgb_centroid_values)
    % Determine each color by setting thresholds for each color
    marker_num = size(rgb_centroid_values);
    colors =[];
    for i = 1:marker_num(1)
        if (rgb_centroid_values(i, 1) >= 180) && (rgb_centroid_values(i, 2) >= 180)
            colors = [colors; "yellow"];

        elseif ((rgb_centroid_values(i, 2) <= 150) && (rgb_centroid_values(i, 1)>= 180))
            colors = [colors; "red"];

        elseif ((rgb_centroid_values(i, 1) < 150) && (rgb_centroid_values(i,3) >= 150))
            colors = [colors; "blue"]; 
        else
            colors = [colors; "green"];
        end
    end
end

function angle = angle_finder(centroid_locations)
    angle = [];
    marker_num = size(centroid_locations);
    for i = 1:marker_num
        y_displacement_temp = 240 - centroid_locations(i,1);
        x_displacement_temp = 320 - centroid_locations(i,2);
        marker_temp = atan2d(y_displacement_temp, x_displacement_temp);
        angle = [angle; marker_temp];
    end
end

function plot_centroids(Image_Markers, centroid_locations, centroid_colors)
    %Plots the original image with each centroid, x,y of centroid, and its
    %color
    figure();
    imshow(Image_Markers)
    hold on;
    plot(320,240,'kO','MarkerFaceColor','k');
    
    items = size(centroid_locations);
    for i = 1:items(1)
        y_temp = centroid_locations(i,2);
        x_temp = centroid_locations(i,1);
        plot(y_temp, x_temp,'kO','MarkerFaceColor','k');
        text(y_temp+20, x_temp, sprintf('%0.0f, %0.0f', round(y_temp), round(x_temp)))
        text(y_temp+20, x_temp+20, sprintf('%s', centroid_colors(i)))
        text(y_temp, x_temp-20, sprintf('%0.0f',i));
    end
end

