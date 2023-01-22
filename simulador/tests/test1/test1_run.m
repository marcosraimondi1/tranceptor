%% Test 1 - Ejercicio 2
% - BER vs EbNo con canal B2B

% Barrer BER vs EbNo y hacerlo para diferentes steps y diferentes numeros
% de coeficientes
clc;clearvars;close all;
%% 
% Levantado de Configuracion
config = readjson('config.json');
sim_config = config.simulator; 
test_config = config.test;

%% Parametros de Barrido
fileName = test_config.fileName;
folderNameT = test_config.folderName; % template
EbnoMax = test_config.EbnoMax;
EbnoMin = test_config.EbnoMin;
EbnoStep = test_config.EbnoStep;

frameSize = test_config.frameSize;  % largo de simulacion
EbnoVec = EbnoMin:EbnoStep:EbnoMax; % vector de EbNo
maxSymbols = 10; % number of symbols represent 100%
max = length(EbnoVec);
%% BER simulada
for n = 1:length(EbnoVec)
    actual_percentage = fix(n*100/max);
    completed_symbols = fix(actual_percentage*maxSymbols/100);
    loading_bar = "";
    for y = 1:maxSymbols
        if y < completed_symbols
            loading_bar = loading_bar + char(9899);
        else
            loading_bar = loading_bar + char(9898);
        end            
    end
    fprintf("%s %i completed\n",loading_bar,actual_percentage)
    EbNo = EbnoVec(n); % nuevo EbNo
    sim_config.channel.EbNo = EbNo;

    % bits
    bits = randi([0 1], 1, frameSize);

    % transceptor
    odata = main(sim_config, bits);

    % ber
    ber_sim = odata.errorData(1)/odata.errorData(2);

    % segun el libro <<BER_LEE.PNG>>
    ... the Q-function is the tail distribution 
    ... function of the standard normal distribution
%             b = log2(M);
%             ber_lee = 4/b*(1-2^(-b/2))*qfunc(sqrt(3*b*10^(EbNo/10)/(2^b-1)));
    % guardar informacion
    odata.ber_sim = ber_sim;
    folderName = sprintf(folderNameT,sim_config.transmisor.M,sim_config.channel.EbNo);
    savedata(folderName,fileName,odata);
end

