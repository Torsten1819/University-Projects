%homework for image and video processing
%get file, take dct, keep various levels of coefficients
%written by Dustin Howe 3/21

%get image file and path to it
[filename, path] = uigetfile('*.*', 'Select an Image File');
filepath = strcat(path, filename);

%load image
pic = imread(filepath);

%add offset before doing dct
pic2 = single(pic) -128;

%we need to pad the image to fit for 8x8 dct blocks
padded_pic = padding(pic2);

%pre-allocate space for dct
dct = zeros(size(padded_pic));
[m,n,z] = size(padded_pic);

%for each color channel, for each 8x8 block do the DCT
for q = 1:z
    for i = 1:8:m
        for j = 1:8:n
            dct(i:(i+7), j:(j+7), q) = DCT_2D(padded_pic(i:(i+7), j:(j+7), q));
        end
    end
end

%create different masked versions of the dct
%masking follows the zigzag pattern
[p_100, p_75, p_50, p_25, z_100, z_75, z_50, z_25] = masking(dct);

%plot the masking pattern and display
[test_100, test_75, test_50, test_25] = masking(ones(8,8));
disp("100% of coeff bit-mask")
disp(test_100)

disp("75% of coeff bit-mask")
disp(test_75)

disp("50% of coeff bit-mask")
disp(test_50)

disp("25% of coeff bit-mask")
disp(test_25)

%pre-allocate space for the idct
idct_100 = zeros(size(padded_pic));
idct_75 = zeros(size(padded_pic));
idct_50 = zeros(size(padded_pic));
idct_25 = zeros(size(padded_pic));

%for each image, for each color channel, do 8x8 block IDCT
for q = 1:z
    for i = 1:8:m
        for j = 1:8:n
            idct_100(i:(i+7), j:(j+7), q) = IDCT_2D(p_100(i:(i+7), j:(j+7), q));
            idct_75(i:(i+7), j:(j+7), q) = IDCT_2D(p_75(i:(i+7), j:(j+7), q));
            idct_50(i:(i+7), j:(j+7), q) = IDCT_2D(p_50(i:(i+7), j:(j+7), q));
            idct_25(i:(i+7), j:(j+7), q) = IDCT_2D(p_25(i:(i+7), j:(j+7), q));
        end
    end
end

padded_pic = int16(padded_pic + 128);

%convert back to integers
idct_100 = int16(idct_100);
idct_75 = int16(idct_75);
idct_50 = int16(idct_50);
idct_25 = int16(idct_25);


%plot all four images
figure
subplot(2,2,1);
image(uint8(idct_100))
title("100%")
subplot(2,2,2);
image(uint8(idct_75))
title("75%")
subplot(2,2,3);
image(uint8(idct_50))
title("50%")
subplot(2,2,4);
image(uint8(idct_25))
title("25%")

%get distance from original to idct images
manh_100 = abs(padded_pic - idct_100);
manh_75 = abs(padded_pic - idct_75);
manh_50 = abs(padded_pic - idct_50);
manh_25 = abs(padded_pic - idct_25);

[a,b,c] = size(manh_100);

%get mse for each image
mse_100 = sum(sum(sum(manh_100.^2)./a)./b)./c;
mse_75 = sum(sum(sum(manh_75.^2)./a)./b)./c;
mse_50 = sum(sum(sum(manh_50.^2)./a)./b)./c;
mse_25 = sum(sum(sum(manh_25.^2)./a)./b)./c;

%display the peak signal-to-noise ratio
psnr_100 = 10*log10((255^2)./mse_100);
psnr_75 = 10*log10((255^2)./mse_75);
psnr_50 = 10*log10((255^2)./mse_50);
psnr_25 = 10*log10((255^2)./mse_25);

disp("PSNR for 100% of Coeff: " + psnr_100 + " dB")
disp("PSNR for 75% of Coeff: " + psnr_75 + " dB")
disp("PSNR for 50% of Coeff: " + psnr_50 + " dB")
disp("PSNR for 25% of Coeff: " + psnr_25 + " dB")




%%% FUNCTIONS %%%

%function to give back 4 masked versions of the dct
function [p_100, p_75, p_50, p_25, z_100, z_75, z_50, z_25] = masking(img)
    [m,n,z] = size(img);
    p_100 = zeros(size(img));
    p_75 = zeros(size(img));
    p_50 = zeros(size(img));
    p_25 = zeros(size(img));
    
    %for each channel, each 8x8 block, do masking for the percentage
    for q = 1:z
        for i = 1:8:m
            for j = 1:8:n
                p_100(i:(i+7), j:(j+7), q)  = bit_mask(img(i:(i+7), j:(j+7), q), 100);
                p_75(i:(i+7), j:(j+7), q) = bit_mask(img(i:(i+7), j:(j+7), q), 75);
                p_50(i:(i+7), j:(j+7), q) = bit_mask(img(i:(i+7), j:(j+7), q), 50);
                p_25(i:(i+7), j:(j+7), q) = bit_mask(img(i:(i+7), j:(j+7), q), 25);
            end
        end
    end
end

%function to does zigzag ordering and masks the removed coefficients
function masked = bit_mask(img, percent)
    masked = zeros(size(img));
    
    %current index
    idx = 1;
    idy = 1;
    
    %four states of our zigzag state machine
    s1 = 1;
    s2 = 0;
    s3 = 0;
    s4 = 0;
    
    %calculate the cuttoff index
    cutoff = round((percent./100).*64);
    
    %for each of the 64 indexes
    for i = 1:64
        %if the index is below cuttoff, keep it, otherwise set to zero
        if i <= cutoff
            masked(idx, idy) = img(idx, idy);
        else
            masked(idx, idy) = 0;
        end
        
        %state machine to determine which direction to traverse the matrix
        %this took awhile to figure out
        if s1 == 1
            idy = idy +1;
            
            if idx == 1
                s1 = 0;
                s2 = 1;
            elseif idx == 8
                s1 = 0;
                s4 = 1;
            end
        elseif s2 == 1
            idx = idx + 1;
            idy = idy -1;
            
            if idy == 1 && idx == 8
                s1 = 1;
                s2 = 0;
            elseif idy == 1
                s2 = 0;
                s3 = 1;
            elseif idx == 8
                s1 = 1;
                s2 = 0;
            end
        elseif s3 == 1
            idx = idx +1;
            
            if idy == 1
                s3 = 0;
                s4 = 1;
            elseif idy == 8
                s2 = 1;
                s3 = 0;
            end
        elseif s4 == 1
            idx = idx -1;
            idy = idy +1;
            
            if idx == 1
                s1 = 1;
                s4 = 0;
            elseif idy == 8
                s3 = 1;
                s4 = 0;
            end
        end
    end
end

%outer function 2d DCT, splits the dct into 2 1-d dcts
function dct = DCT_2D(img)
    dct = zeros(8,8);
    
    %first is applied to original image
    for i = 1:8
        dct(i,:) = DCT_1D(img(i,:), 0);
    end
    
    %second is applied to result of the first one
    for i = 1:8
        dct(:,i) = DCT_1D(dct(:,i), 1);
    end
end

%out function for 2d idct
function idct = IDCT_2D(img)
    idct = zeros(8,8);
    
    %the idct is separable
    for i = 1:8
        idct(:,i) = IDCT_1D(img(:,i), 0);
    end
    for i = 1:8
        idct(i,:) = IDCT_1D(idct(i,:), 1);
    end
    
    %add back in the offset
    idct = (idct + 128);
    
end

%function to padd the image
function padded_pic = padding(pic)
    [m, n, z] = size(pic);
    
    %determine the new bounds of the padded image based on modulus division
    %by the step size
    if mod(m,8) ~= 0
        new_m = m + (8 - mod(m,8));
    else
        new_m = m;
    end
    
    %do the same for other axis
    if mod(n,8) ~= 0
        new_n = n + (8 - mod(n,8));
    else
        new_n = n;
    end
    
    %copy the image to the padded space
    padded_pic = zeros(new_m, new_n, z);
    padded_pic(1:m, 1:n, :) = pic;
    
    %for the boundaries of the padded space, copy the edge pixel
    for i = m:new_m
        padded_pic(i,:,:) = padded_pic(i-1, :, :);
    end
    for i = n:new_n
        padded_pic(:,i,:) = padded_pic(:,i-1, :);
    end
    
end

%1 dimensional dct - dones as matrix multiplication by coefficient matrix
%of the basis
function dct = DCT_1D(img, dir)

    %coeffiecent matrix is pre-calculated in python
    coeff = [0.35355339,  0.49039264,  0.46193977,  0.41573481,  0.35355339,  0.27778512, 0.19134172,  0.09754516; ...
        0.35355339,  0.41573481,  0.19134172, -0.09754516, -0.35355339, -0.49039264, -0.46193977, -0.27778512; ...
        0.35355339,  0.27778512, -0.19134172, -0.49039264, -0.35355339,  0.09754516, 0.46193977,  0.41573481; ...
        0.35355339,  0.09754516, -0.46193977, -0.27778512,  0.35355339,  0.41573481, -0.19134172, -0.49039264; ...
        0.35355339, -0.09754516, -0.46193977,  0.27778512,  0.35355339, -0.41573481, -0.19134172,  0.49039264; ...
        0.35355339, -0.27778512, -0.19134172,  0.49039264, -0.35355339, -0.09754516, 0.46193977, -0.41573481; ...
        0.35355339, -0.41573481,  0.19134172,  0.09754516, -0.35355339,  0.49039264, -0.46193977,  0.27778512; ...
        0.35355339, -0.49039264,  0.46193977, -0.41573481,  0.35355339, -0.27778512, 0.19134172, -0.09754516];
    
    %multiple vector by matrix to get new vector for that row or column
    %matrix is transposed because matlab is annoying
    if dir == 0
        dct = coeff'*img';
    else
        dct = coeff'*img;
    end


end

%1 dimensional idct
function idct = IDCT_1D(img, dir)
    %same precalculated coeffecient matrix for basis 
    coeff = [0.35355339,  0.49039264,  0.46193977,  0.41573481,  0.35355339,  0.27778512, 0.19134172,  0.09754516; ...
        0.35355339,  0.41573481,  0.19134172, -0.09754516, -0.35355339, -0.49039264, -0.46193977, -0.27778512; ...
        0.35355339,  0.27778512, -0.19134172, -0.49039264, -0.35355339,  0.09754516, 0.46193977,  0.41573481; ...
        0.35355339,  0.09754516, -0.46193977, -0.27778512,  0.35355339,  0.41573481, -0.19134172, -0.49039264; ...
        0.35355339, -0.09754516, -0.46193977,  0.27778512,  0.35355339, -0.41573481, -0.19134172,  0.49039264; ...
        0.35355339, -0.27778512, -0.19134172,  0.49039264, -0.35355339, -0.09754516, 0.46193977, -0.41573481; ...
        0.35355339, -0.41573481,  0.19134172,  0.09754516, -0.35355339,  0.49039264, -0.46193977,  0.27778512; ...
        0.35355339, -0.49039264,  0.46193977, -0.41573481,  0.35355339, -0.27778512, 0.19134172, -0.09754516];
    
    %get idct for each row and column by multiplying vector and matrix,
    %this is not transponsed
    if dir == 0
        idct = coeff*img;
    else
        idct = coeff*img';
    end
end