function [success] = savedata(folder,file,data)
%SAVEDATA Summary of this function goes here
%   Parameters:
%   -   folder: folder name to save data
%   -   file: file name to save data (overwrite)
%   -   data: struct with data to save

    file_path = strcat(folder,"/",file);
    try
        if isfolder(folder)
            writetable(struct2table(data,'AsArray',true), file_path);
        else
%             fprintf("Creating Folder: %s \n", folder)
            mkdir(folder)
            writetable(struct2table(data,'AsArray',true), file_path);
        end
        success = 1;
    catch exception
        fprintf("Failed to save data to file \n Error: %s",exception.identifier)
        success = 0;
    end
end

