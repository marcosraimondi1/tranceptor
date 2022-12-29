%% Process Test 1
% Barrer BER vs EbNo y hacerlo para diferentes steps y diferentes numeros
% de coeficientes
clc;clearvars;close all;

% Levantado de Configuracion
config = readjson('config.json');
sim_config = config.simulator;
test_config = config.test;

% Parametros de Barrido
fileName = test_config.fileName;
folderNameT = test_config.folderName; % template
EbnoMax = test_config.EbnoMax;
EbnoMin = test_config.EbnoMin;
EbnoStep = test_config.EbnoStep;

frameSize = test_config.frameSize;  % largo de simulacion
EbnoVec = EbnoMin:EbnoStep:EbnoMax; % vector de EbNo

% Levantado de Datos
ber_simulada = zeros(1,length(EbnoVec));
ber_teo = zeros(1,length(EbnoVec));

for n = 1:length(EbnoVec)
    EbNo = EbnoVec(n);
    folderName = sprintf(folderNameT,sim_config.transmisor.M,EbNo);
    data = readdata(folderName,fileName);
    ber_simulada(n) = data.ber_sim;
    ber_teo(n) = berawgn(EbNo, 'qam', sim_config.transmisor.M);
end

%% BER vs EbNo
figure
semilogy(EbnoVec, ber_teo, 'LineWidth',2)     % teorica
hold on
semilogy(EbnoVec, ber_simulada,'-^', 'LineWidth',2)    % simulada
grid on
title("Bit Error Rate vs EbNo")
xlabel("EbNo[dB]")
ylabel("BER")
% ylim([1e-8, 5e-1])
legend("Teorica", "Simulada")
