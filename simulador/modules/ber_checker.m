function [odata] = ber_checker(config)
% ber_checker; alinear entradas y salida y calcular errores
% parámetros, struct config con:
%   - crop_percentage: porcentaje de recorte para evitar transitorio
%   - bitsOut: bits recibidos en el receptor
%   - bitsIn: bits transmitidos
%% Parameters    
    crop_percentage = config.crop_percentage;    
    bitsOut = config.bitsOut;
    bitsIn = config.bitsIn;
    
    %% Crop - medir ber cuando el sistema este en estado estacionario
    crop = fix(length(bitsOut)*crop_percentage/100); % crop index
    bitsOut = bitsOut(crop:end);
    bitsIn = bitsIn(crop:length(bitsOut)+crop-1);

    %% Error Calculation
    % BER = cantidad de errores / cantidad de bits 
    errorData = zeros(2,1);
    [errorData(1), ~] = biterr(bitsIn, bitsOut.');  % cantidad de errores
    errorData(2)= length(bitsIn);                   % cantidad de bits
    
    %% OUTPUT
    odata.errorData = errorData;
end