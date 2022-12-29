%% Process Test 2
% Capacidad de enganche del sistema
% de coeficientes
clc;clearvars;close all;

% Levantado de Configuracion
config = readjson('config.json');
sim_config = config.simulator;
test_config = config.test;

% Parametros de Barrido
fileName = test_config.fileName;
folderNameT = test_config.folderName; % template
carrier_errors = test_config.carrier_errors;

% Levantado de Datos
frameSize = test_config.frameSize;  % largo de simulacion
errorsI = zeros(length(carrier_errors),frameSize/2);

for n = 1:length(carrier_errors)
    carrier_error = carrier_errors(n); % nuevo EbNo
    folderName = sprintf(folderNameT,sim_config.transmisor.M,sim_config.channel.EbNo,carrier_error);
    data = load(strcat(folderName,"/",fileName));
    errorI = data.errorI;
    errorsI(n,1:length(errorI)) = errorI;
end

%% Curvas de capacidad de enganche
figure
grid on
hold on
title("Curvas de Capacidad de Enganche")
legends = strings(1,length(carrier_errors));
for n = 1:length(carrier_errors)
    plot(errorsI(n,:)*1.25e3, 'LineWidth',2)
    legends(n) = sprintf("%d MHz", carrier_errors(n)/1e6);
end
legend(legends)
ylabel("FCR Integral Branch MHz")