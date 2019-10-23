% Import image files and separate into 6 subimages
d = dir('41001/41001*.jpg'); % list files in current folder that match 41001. * means all files matching 41001 
nd = length(d); % return number of elements in d. there are 715 images in d 
ncpsi = 2880/6; %480; % #columns per subimage (row*column)
nrvp  = 300-30; 270; % #valid pixel rows (not footer)
iBlank = false(nd,1); % 1 for blank pic & 0 for good pic 
 
% not needed 
%point11_starthorizon = 100; 
%point12_starthorizon = 100; 
%point21_endhorizon = 1134; 
%point22_endhorizon = 430;

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
        
        % not needed 
        % after getting longest line, find endpoints of only horizon line ("red" line)  
        % coordinates of longest line can be found in "lines" variable 
        % if coordinates point 1 & point 2 of horizon are b'w these points,
        % then pic has horizon, else not 
        
        %x1 = xy_long(1,1);
        %y1 = xy_long(1,2);
        %x2 = xy_long(2,1);
        %y2 = xy_long(2,2);
        
        %if (x1 > point11_starthorizon && y1 > point12_starthorizon && x2 <= point21_endhorizon && y2 <= point22_endhorizon)
         %  fprintf(['horizon found in image',s,'/',num2str(j) '\n']); 
        %else  
         %   warning(['No horizon found in image',s,'/',num2str(j) '\n']);
        %end 
        
        % determine 
        K2 = zeros(size(K,1)-1,size(K,2));
        bflr = zeros(1,480); dbflmgr = zeros(1,480);
        for i = 2:270 %#ok<*FXSET>
            K2(i-1,:) = double(K(i,:))-double(K(i-1,:));
        end
        [mK2,imK2] = min(K2);
        hold on
        plot(1:480,imK2,'m.','LineWidth',2)
        pc = polyfit(1:480,imK2,1);
        for j = 1:480
            bflr(j) = pc(1)*j+pc(2);
            dbflmgr(j) = abs(bflr(j)-imK2(j));
        end
        outliers = find(dbflmgr>50);
        imK3 = imK2;
        imK3(outliers) = [];
        ximK3 = 1:480; ximK3(outliers) = [];
        pc = polyfit(ximK3,imK3,1);
        fplot(@(x)pc(1)*x+pc(2),[1,480])
       
            drawnow;
            saveas(1,['output',filesep,s(7:end-4),'_',num2str(j),'.png'],'png');
            close(1);
        end
       
 end
end