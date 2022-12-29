%% Ejercicio 1 - TP6
% a) Plotear constelacion de y[k] al principio y final de la etapa 1
% b) Plotear constelacion de y_FCR[k] al principio y final de la etapa 2
% c) Plotear la evolucion de la rama integral del CR
clc;clearvars;close all;
% Levantado de Configuracion
config = readjson('base_config.json');
sim_config = config.simulator; 
test_config = config.test;

% Simulacion
bits = randi([0 1], 1, test_config.frameSize); % simulation bits
odata = main(sim_config, bits);

% Guardado de Datos
% fileName = test_config.fileName;
% folderName= sprintf(test_config.folderName,sim_config.transmisor.M,sim_config.channel.EbNo,sim_config.transmisor.rolloff);
% savedata(folderName,fileName,odata);
% 
% Lectura de Datos
% datar = readdata(folderName,fileName);
