function atomNum = getAtomNumbers(images, params, varargin)
%% GETATOMNUMBERS is a function that gets atom numbers for a series of images


croplength = 170;
bglength = 30;

leftedge = 51;
bottomedge = 300;

%% Default values
ROI = [ leftedge bottomedge croplength croplength];
bgROI = [leftedge bottomedge-bglength  croplength bglength];

%% specified ROIs
switch nargin
    case 3
        ROI = varargin{1};
    case 4
        ROI = varargin{1};
        bgROI = varargin{2};
end

%% Load the images

data = dataLoad(images);

%% Process images (crop, rotate, etc)

processedData = dataProcess(data,ROI,bgROI);

%% Extract information

atomNum = countAtoms(processedData);

%% Plot your favorite stuff
figure(2)
plot(cell2mat(params),cell2mat(atomNum),'.', 'MarkerSize', 30)

end

function atomNum = countAtoms(data)

    %mag_high=15.6472; % high magnification
    pixellength=16*10^-6; %size of pixel in m
    pixelsize=pixellength^2/3.05^2; % pixelsize on atoms
    ImgLambda = 671*10^(-9); %in meter
    Sigma0 = 3* ImgLambda^2 / (2*pi); % scattering cross section for the cycling transition
    Nsat=1.3357e+05;

    for i=1:length(data)
        imageData = data(i).img;
        
        atomNum{i} = sum(sum(imageData)) * pixelsize/Sigma0;
        
    end



end


function processedData = dataProcess(data,ROI,bgROI)
%% RFPROCESS rotates and slices the raw images
    figure(1)
    
    % Populate spectra
    for i=1:length(data)
        
        rawImage = data(i).img;
        croppedImage = imcrop(rawImage,ROI);
        bgImage = imcrop(rawImage,bgROI);
        [bx,by]=size(bgImage);
        bgCounts = sum(sum(bgImage))/(bx*by);
        correctedImage = croppedImage - bgCounts;
        processedData(i).img = correctedImage;
    end
    subplot(1,2,1)
    imagesc(correctedImage)
    axis image
    title('sample cropped Image')
    
    subplot(1,2,2)
    imagesc(bgImage)
    axis image
    title('sample bg Image')
end


function data = dataLoad(images)
%% RFLOAD loads the raw images as OD arrays
    % Initialize data struct
    data(1:length(images)) = struct('name','','img',[],'rf',0);
    % Load the images from the filenames
    fprintf('\n');
    for i =1:length(images)
        fprintf('.');
        data(i).name = images{i};
        data(i).img=loadfitsimage(data(i).name);
    end
    fprintf('\n');
end


function img = loadfitsimage(filename)
 data=fitsread(filename);
    absimg=(data(:,:,2)-data(:,:,3))./(data(:,:,1)-data(:,:,3));


%replace the pixels with a value of negtive number,0 or inf or nan by the
%average of nearset site.
    ny=size(absimg,1);
    nx=size(absimg,2);
    burnedpoints = absimg <= 0;
    infpoints = abs(absimg) == Inf;
    nanpoints = isnan(absimg);
    Change=or(or(burnedpoints,infpoints),nanpoints);
    NChange=not(Change);
    for i=2:(ny-1)
        for j=2:(nx-1)
            if Change(i,j)
                n=0;
                rp=0;
                if NChange(i-1,j)
                    rp=rp+absimg(i-1,j);
                    n=n+1;
                end
                if NChange(i+1,j)
                    rp=rp+absimg(i+1,j);
                    n=n+1;
                end
                if NChange(i,j-1)
                    rp=rp+absimg(i,j-1);
                    n=n+1;
                end
                if NChange(i,j+1)
                    rp=rp+absimg(i,j+1);
                    n=n+1;
                end
                if (n>0)
                    absimg(i,j)=(rp/n);
                    Change(i,j)=0;
                end
            end
        end
    end
    absimg(Change)=1;
    img = log(absimg);
end
