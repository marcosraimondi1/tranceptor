%% Ejercicio 4
% trazar curvas de BER vs EbNo y
% curvas de penalidad vs ancho de banda
% en los siguientes casos:
% A) limitacion de BW antes del ruido
% B) limitacion de BW despues del ruido
clc;clearvars;close all;
% Levantado de Configuracion
config = readjson('base_config.json');
sim_config = config.simulator; 
test_config = config.test;

% Simulacion
bits = randi([0 1], 1, test_config.frameSize); % simulation bits
odata = main(sim_config, bits);

% Guardado de Datos
fileName = test_config.fileName;
folderName= sprintf(test_config.folderName,sim_config.M,sim_config.EbNo,sim_config.rolloff);
savedata(folderName,fileName,odata);

% Lectura de Datos
datar = readdata(folderName,fileName);
