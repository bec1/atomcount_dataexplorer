function [params,atomNum] = runExperiment(varargin)

%% Define inputs
    switch nargin
        case 0
            exp_name = 'experiment_1';
        case 1
            exp_name = varargin{1};
            if ~ischar(exp_name)
                msgbox('Please enter a string for the experiment name');
            end
    end
               
 %% Define paths           
    addpath('Snippet_Readout');

    raw_data_path = 'Y:\Elder Backup Raw Images';
    processed_data_path = 'C:\Users\BEC1\Dropbox (MIT)\BEC1\Processed Data';
    
    [sourcedir,tempfolder,destination] = foldermanagement(raw_data_path,processed_data_path,exp_name);

 %% Find files and param values
 
    [files,params] = findfiles(sourcedir);
 
    
 %% Calculate RF spectra
    
    atomNum = getAtomNumbers(files,params);
    
    params = cell2mat(params);
    atomNum = cell2mat(atomNum);
    
    
    
end


function [sourcedir,tempfolder,destination] = foldermanagement(raw_data_path,processed_data_path,exp_name)
% prepare the folders to get raw data from, copy to while working, and
% finally save to after finishing.
    c=clock;
    year = num2str(c(1));
    month = strcat(year,'-',num2str(c(2)));
    day = strcat(month,'-',num2str(c(3),'%02d'));

    sourcedir = strcat(raw_data_path,'\',year,'\',month,'\',day);
    tempfolder = strcat('C:\',year,'\',month,'\',day);
    destination=strcat(processed_data_path,'\',year,'\',month,'\',day,'\',exp_name); % Put the image files in here

    if not(isdir(sourcedir))
        sourcedir = strcat(raw_data_path,'\',year,'\',month);
        if not(isdir(sourcedir))
            sourcedir = strcat(raw_data_path,'\',year);
            if not(isdir(sourcedir))
                sourcedir = strcat(raw_data_path);
            end
        end
    end
    if not(isdir(tempfolder))
        mkdir(tempfolder);
    end
    if not(isdir(destination))
        mkdir(destination);
    end
end

function [files, params] = findfiles(sourcedir)
   
    %% Load images
    f = msgbox('Select all the images in the dataset');
    waitfor(f);
    [filenames,PathName,~] = uigetfile('*.fits','Select the dataset',sourcedir,'MultiSelect','on');
    files = strcat(PathName,filenames);
    
    paramName = inputdlg('Enter the name of the parameter you varied');
    
    for i=1:length(filenames)
        img_name = filenames{i};
        snipout = GetSnippetValues(img_name,paramName);
        params{i} = str2double(snipout.value{1});
    end
    
end







