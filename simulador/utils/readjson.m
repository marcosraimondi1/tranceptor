function odata = readjson(fileName)
%READJSON reads json file, struct output
    fid = fopen(fileName);      % Opening the file
    raw = fread(fid,inf);       % Reading the contents
    str = char(raw');           % Transformation
    fclose(fid);                % Closing the file
    odata = jsondecode(str);   % parse JSON from string to struct
end

