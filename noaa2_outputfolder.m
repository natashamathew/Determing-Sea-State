% Import image files and separate into 6 subimages
d = dir('41001/41001*.jpg'); % list files in current folder that match 41001. * means all files matching 41001 
nd = length(d); % return number of elements in d. there are 715 images in d 
ncpsi = 2880/6; %480; % #columns per subimage (row*column)
nrvp  = 300-30; 270; % #valid pixel rows (not footer)
iBlank = false(nd,1); % 1 for blank pic & 0 for good pic 



for i = 1:nd % For each image
 I = imread(d(i).name); % read image from file 
 if all(I(1:10,1:10,:)<6) % Blank image; skip
     iBlank(i) = true;
 end
end
iValid = find(~iBlank); % not blank pic (nvi)
nvi = length(iValid); % #valid images: nvi = 402
J = cell(nvi,6); S = J; % J creates a cell array of (402,6) since 6 images per pic 
results = zeros(nvi,6);
for i = 1:nvi % For each Valid Image
 s = d(iValid(i)).name;
 I = imread(s); % Read image from graphics file from s 
 for j = 1:6 % For each subimage (of 6)
     J{i,j} = I(1:nrvp,((j-1)*ncpsi+1):(j*ncpsi),:); % ~understand 
     K = rgb2gray(J{i,j}); % rgb2gray converts the truecolor image RGB to the grayscale intensity image K
     
     [BW2,tp] = edge(K,'Prewitt'); % Find edges in intensity image using Prewitt method  BW = edge(I,method)
    
     [H,T,R] = hough(BW2);
     
     % Find the peaks in the Hough transform matrix, H, using the houghpeaks function.
     P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
     % Superimpose a plot on the image of the transform that identifies the peaks.
     x = T(P(:,2)); y = R(P(:,1)); 
     
     % Find lines in the image using the houghlines function. 
     lines = houghlines(BW2,T,R,P,'FillGap',5,'MinLength',7);
        if ~isempty(lines)
            results(i,j) = length(lines);
     % Create a plot that displays the original image with the lines superimposed on it.
     figure(1), clf; imshow(K), hold on
     max_len = 0;
     for k = 1:length(lines)
         xy = [lines(k).point1; lines(k).point2];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
         % Plot beginnings and ends of lines
         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
         % Determine the endpoints of the longest line segment
         len = norm(lines(k).point1 - lines(k).point2);
         if ( len > max_len)
             max_len = len;
             xy_long = xy;
         end
     end
        %highlight the longest line segment (horizon) 
        plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
        
            
            drawnow;
            saveas(1,['output',filesep,s(7:end-4),'_',num2str(j),'.png'],'png');
            close(1);
        end
       
 end
end