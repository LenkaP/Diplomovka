% Clear the existing workspace
clear all;
  
% Clear the command window
clc;
  
% Getting the input image  
filename = '\Users\lenkapetnuchova\Desktop\DP\jpegprotected\New Folder\output_crypted_img.xlsx';
input_image = xlsread(filename);
  
% Get height and width for traversing through the image
height = size(input_image, 1);
width = size(input_image, 2);
  
% Number of characters of the hidden text
chars = 12;
  
% Number of bits in the message
message_length = chars * 8;
  
% counter to keep track of number of bits extracted
counter = 1;
  
% Traverse through the image
for i = 1 : height
    for j = 1 : width
          
        % If more bits remain to be extracted
        if (counter <= message_length)
              
            % Store the LSB of the pixel in extracted_bits
            extracted_bits(counter, 1) = mod(double(input_image(i, j)), 2);
              
            % Increment the counter
            counter = counter + 1;
        end
    end
end
  
% Powers of 2 to get the ASCII value from binary
binValues = [ 128 64 32 16 8 4 2 1 ];
  
% Get all the bits in 8 columned table
% Each row is the bits of the character 
% in the hidden text
binMatrix = reshape(extracted_bits, 8, (message_length/8));
  
% Convert the extracted bits to characters
% by multiplying with powers of 2
textString = char(binValues*binMatrix); 
  
% Print the hidden text
disp(textString);