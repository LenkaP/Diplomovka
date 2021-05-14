% Clear the existing workspace
clear all;
  
% Clear the command window
clc;
  
% Read the input image
input = imread('8.png');
ti=size(input);
figure,imshow(input);
title('Original image'); 
xlabel(['Rozmer image : ',num2str(ti(2)),'x',num2str(ti(1))])
ImageSize = 8*prod(size(input))

% Convert image to greyscale
input=rgb2gray(input);
ti2=size(input);
figure,imshow(input);
title('GRAY image'); 
xlabel(['Rozmer''image : ',num2str(ti2(2)),'x',num2str(ti2(1))])

% Resize the image to required size
input=imresize(input, [512 512]);
ti3=size(input);
figure,imshow(input);
title('RESIZE image');
xlabel(['Rozmer''image : ',num2str(ti3(2)),'x',num2str(ti3(1))])


% Message to be embedded
message='1234556AµDADASD f sdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdfsdfgsdf dfg d  67898765432';
disp('Message: ')
disp(message) 

% Length of the message where each character is 8 bits
len = length(message) * 8;
  
% Get all the ASCII values of the characters of the message
ascii_value = uint8(message);
  
% Convert the decimal values to binary
bin_message = transpose(dec2bin(ascii_value, 8));
  
% Get all the binary digits in separate row
bin_message = bin_message(:);
  
% Length of the binary message
% Length of the binary message
N = length(bin_message);
disp('LENGTH OF MESSAGE IN BITS');
disp(N);
  
% Converting the char array to numeric array
bin_num_message=str2num(bin_message);
  
% Initialize output as input
output = input;
  
% Get height and width for traversing through the image
height = size(input, 1);
width = size(input, 2);
  
% Counter for number of embedded bits
embed_counter = 1;
 lsb_counter = 0; 

% Calculate number of LSB which can be changed in image
for i = 1 : height
    for j = 1 : width
       LSB = mod(double(input(i, j)), 2); 
       if(LSB == 1)
           lsb_counter = lsb_counter+1;
       end
    end
end
disp('MAX NUMBER OF LSB BITS THAT CAN BE EMBEDED INTO IMAGE')
disp(lsb_counter)

% Traverse through the image
for i = 1 : height
    for j = 1 : width
          
        % If more bits are remaining to embed
        if(embed_counter <= len)
              
            % Finding the Least Significant Bit of the current pixel
            LSB = mod(double(input(i, j)), 2);
              
            % Find whether the bit is same or needs to change
            temp = double(xor(LSB, bin_num_message(embed_counter)));
              
            % Updating the output to input + temp
            output(i, j) = input(i, j)+temp;
              
            % Increment the embed counter
            embed_counter = embed_counter+1;
        end
          
    end
end
  
% Write both the input and output images to local storage
imwrite(input, '\Users\lenkapetnuchova\Desktop\DP\jpegprotected\JPEG\originalImage.png');
imwrite(output, '\Users\lenkapetnuchova\Desktop\DP\jpegprotected\JPEG\stegoImage.png');