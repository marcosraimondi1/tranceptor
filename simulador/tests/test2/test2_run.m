%% Test 2 - Ejercicio 3
% - Analisis de capacidad de enganche del sistema
clc;clearvars;close all;
%% 
% Levantado de Configuracion
config = readjson('config.json');
sim_config = config.simulator; 
test_config = config.test;

%% Parametros de Barrido
fileName = test_config.fileName;
folderNameT = test_config.folderName; % template
carrier_errors = test_config.carrier_errors;

frameSize = test_config.frameSize;  % largo de simulacion

%% Barrido de frecuencias
for n = 1:length(carrier_errors)
    carrier_error = carrier_errors(n); % nuevo EbNo
    sim_config.channel.carrier_error = carrier_error;

    % bits
    bits = randi([0 1], 1, frameSize);
    
    % transceptor
    odata = main(sim_config, bits);
    errorI = odata.ERROR_I;
   % guardar informacion
    folderName = sprintf(folderNameT,sim_config.transmisor.M,sim_config.channel.EbNo,carrier_error);
    mkdir(folderName)
    save(strcat(folderName,"/",fileName),'errorI');
end

