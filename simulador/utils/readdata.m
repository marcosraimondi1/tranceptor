function [odata] = readdata(folder, file)
%READDATA read struct from file
%   Parameters:
%   -   path: path to file

    try
        file_path = strcat(folder,"/",file);
        if isfile(file_path)
            odata = table2struct(readtable(file_path));
        else
            fprintf("No such file: %s",file_path)
        end
    catch exception
        fprintf("Failed to read data from file: %s \n Error: %s",file,exception.identifier)
    end
end

