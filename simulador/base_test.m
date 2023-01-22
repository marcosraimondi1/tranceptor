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

% error integral evolution
error_i = odata.rx.ERROR_I;

%% Guardado de Datos
fileName = test_config.fileName;
folderName= sprintf(test_config.folderName,sim_config.transmisor.M,sim_config.channel.EbNo,sim_config.transmisor.rolloff);
file_path = strcat("./",folderName,"/",fileName);
mkdir(folderName)
save(file_path, 'error_i')

%% Carga de Datos
% load(file_path)
figure
hold on
grid on
title("ERROR INTEGRAL - FCR")
plot(error_i*1.25e3)
legend(sprintf("%d MHz", sim_config.channel.carrier_error/1e6))
ylabel("MHz")