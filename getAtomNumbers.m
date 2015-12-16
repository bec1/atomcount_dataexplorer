function atomNum = getAtomNumbers(imageFilename,ROI,bgROI)

    rawImage = loadfitsimage(imageFilename);
    croppedImage = imcrop(rawImage,ROI);
    bgImage = imcrop(rawImage,bgROI);
    [bx,by]=size(bgImage);
    bgCounts = sum(sum(bgImage))/(bx*by);
    correctedImage = croppedImage - bgCounts;

% atom counting program with back ground calibration


mag_high=15.6472; % high magnification
pixellength=16*10^-6; %size of pixel in m
pixelsize=pixellength^2/3.05^2/(5^2);
ImgLambda = 671*10^(-9); %in meter
% scattering cross section for the cycling transition
Sigma0 = 3* ImgLambda^2 / (2*pi);
Nsat=1.3357e+05;

for i=1:N
    filename=[folder,'\',list{i},'.fits'];
    img=fitsreadRL(filename);
    NumMap = AtomNumber( img,pixelsize,Sigma0, Nsat,500 );
    OD = NumMap(258:411,71:221);
    CR= NumMap(170:250,71:221);
    [y,x]=size(CR);
    NumberCorrection=sum(sum(CR))/(x*y);
    OD=OD-NumberCorrection;
    number(i)=sum(sum(OD));
end


    atomNum = AtomNumber(correctedImage);

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
