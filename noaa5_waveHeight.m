% Initialization
f = pwd;
chf = 0; chnf = 0;
fwind = dir(fullfile(f,'*WIND*.csv'));
fwave = dir(fullfile(f,'*WAVE*.csv'));

% Import image files and separate into 6 subimages
d = dir('41001/41001*.jpg'); % list files in current folder that match 41001. * means all files matching 41001 
nd = length(d); % return number of elements in d. there are 715 images in d 
ncpsi = 2880/6; %480; % #columns per subimage (row*column)
nrvp  = 300-30; 270; % #valid pixel rows (not footer)
iBlank = false(nd,1); % 1 for blank pic & 0 for good pic 

%Read CSV spreadsheets
delimiter = ',';
startRow = 2;
formatSpec = '%q%f%f%f%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(fwind.name,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
windArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
datestr = dataArray{1}; 
windDnum = datenum(datestr,'mm/dd/yyyy HHMM');
knotsPerMps = 1.94384;
windspeed = dataArray{2}*knotsPerMps; 
windspeed10 = dataArray{3}*knotsPerMps; 
windspeed20 = dataArray{4}*knotsPerMps; 
formatSpec = '%s%f%f%f%f%f%f%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
fwavID = fopen(fwave.name,'r');
waveArray = textscan(fwavID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
wavestr = waveArray{1}; 
waveDnum = datenum(wavestr,'mm/dd/yyyy HHMM');
signWaveHeight = waveArray{4}; 
windWaveHeight = waveArray{5}; 
aimgDnum = zeros(nd,1);

%Read CSV spreadsheets
mapWind2Beauf = [1,0; 3,1; 6,2; 10,3; 16,4; 21,5; 27,6; 33,7; 40,8; 47,9; 55,10; 63,11; 64,12; inf,13];
mapWave2Beauf = [0,0; 0.1,1; 0.3,2; 1,3; 1.5,4; 2.5,5; 4,6; 5,7; 7.5,8; 10,9; 12.5,10; 16,11; inf,12]; 
beauf = cell(length(windspeed),2);
for i=1:length(windspeed)
    beauf{i,1} = datestr(i);
    for j=1:length(mapWind2Beauf)
        if windspeed(i)<mapWind2Beauf(j,1)
            beauf{i,2} = mapWind2Beauf(j,2);
            break;
        end
    end
end
for i=1:length(signWaveHeight)
    i2 = find(windDnum==waveDnum(i));
    for j=1:length(mapWave2Beauf)
        if signWaveHeight(i)<mapWave2Beauf(j,1)
            beauf{i2,3} = mapWave2Beauf(j,2);
            break;
        end
    end    
end

for i = 1:nd % For each image
 I = imread(fullfile('41001',d(i).name)); % read image from file 
 if all(I(1:10,1:10,:)<6) % Blank image; skip
     iBlank(i) = true;
 end
     aimgDnum(i) = datenum(d(i).name(7:end-4),'yyyy_mm_dd_HHMM');

end
iValid = find(~iBlank); % not blank pic (nvi)
nvi = length(iValid); % #valid images: nvi = 402
vimgDnum = aimgDnum(iValid);
%for i = 1:nvi
   % idxWave(i) = find(vimgDnum(i) == waveDnum);
   % idxWind(i) = find(vimgDnum(i) == windDnum);
  %  if isempty(idxWave) || isempty(idxWind)
    %    error('Can''t find datenum');
  %  end
%end
%Read CSV spreadsheets

J = cell(nvi,6); S = J; % J creates a cell array of (402,6) since 6 images per pic 
results = zeros(nvi,6);
for i = 1:nvi % For each Valid Image
 s = d(iValid(i)).name;
 I = imread(fullfile('41001',s)); % Read image from graphics file from s 
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
        
        K2 = zeros(size(K,1)-1,size(K,2)); % created an array of all 0's 
        %then Find only the length of the 1st dimension of K.
        bflr = zeros(1,480); % create an array of all zero row, col [row = 1, col 480]
        dbflmgr = zeros(1,480); % create an array of all zero 
        for i = 2:270 %#ok<*FXSET> for all valid pixel 
            K2(i-1,:) = double(K(i,:))-double(K(i-1,:));% 
            % K2(1,:) = double(K(2,:))-double(K(1,:))
            % 1st row of K2 = 2nd row of K - 1st row of K 
        end
        [mK2,imK2] = min(K2);  %mK2(row X) = minimum value of K2 & imK2(col Y) = Index to minimum values of K2
        hold on %Retain current plot when adding new plots
        plot(1:480,imK2,'m.','LineWidth',2) % connect minimum points on Y to a single magneta line 
        pc = polyfit(1:480,imK2,1); %p = polyfit(x,y,n)
        for j = 1:480
            bflr(j) = pc(1)*j+pc(2);%pc(1) is slope & pc(2) is the intercept mx+b
            dbflmgr(j) = abs(bflr(j)-imK2(j)); % find extreme points by subtracting 
            % y intercept - imk2 
        end
        outliers = find(dbflmgr>50);
        imK3 = imK2;
        imK3(outliers) = [];
        ximK3 = 1:480; 
        ximK3(outliers) = [];
        pc = polyfit(ximK3,imK3,1);
        fplot(@(x)pc(1)*x+pc(2),[1,480])
        
        indRowHorizon = polyval(pc,1:480);
        minRowH = min(floor(indRowHorizon)); maxRowH = max(ceil(indRowHorizon));
        indRowHorizon = round(indRowHorizon);
        numRowL = 270-minRowH+1; numRowL2 = 270-maxRowH+1;
        L = NaN(numRowL,480);
        for j = 1:480
            L((indRowHorizon(j)-minRowH+1):numRowL,j) = K(indRowHorizon(j):end,j);
        end
        L2(1:numRowL2,1:480) = K(maxRowH:end,:);
       
        BW3 = edge(L2); %wave edges in binary 
        
            drawnow;
            saveas(1,['output',filesep,s(7:end-4),'_',num2str(j),'.png'],'png');
            close(1);
        end  
 end
end