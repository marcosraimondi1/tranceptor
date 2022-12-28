function odata = FSE(config)
%FSE Fractionally Spaced Equalizer module
% using stochastic gradient descent LMS
% 
% config struct:
%   NTAPS         = cant de coef del ecualizador
%   leak_const    = tap leakeage constant
%   Beta          = learning step
%   Nos           = tasa de sobremuestreo
%   M             = Orden de Modulacion
%   refresh_rate  = animation refresh rate
%   signal        = received signal
%   debug         = 1 -> draw plots and animations

% odata struct:
%   FSE_coefficients = W;     % eq. coefficients
%   EQ_OUT = EQ_OUT;          % eq. output
%   SLICER_OUT = SLICER_OUT;  % symbols detected
%   ERROR = ERROR;            % error evolution

NTAPS         = config.NTAPS;
NFFT          = config.NFFT;
leak_const    = config.leak_const;
Beta          = config.Beta;
Nos           = config.Nos;
M             = config.M;
refresh_rate  = config.refresh_rate;
debug         = config.debug;
signal        = config.signal;
%% FSE

Xbuffer = zeros(NTAPS,1);           % Buffer del ecualizador
W = zeros(1,NTAPS);                 % Coeficientes
W((NTAPS+1)/2) = 1;                 % Inicializando un valor
m = 0;
% frec = linspace(-1,1,NFFT);

symbols = qammod(0:M-1,M);          % posibles simbolos a detectar
a = [unique(real(symbols)); unique(imag(symbols))]; % parte real e imag de simbolos
%% LOGS
EQ_OUT = zeros(1,(length(signal)-NTAPS-1)/2);
SLICER_OUT = zeros(1,(length(signal)-NTAPS-1)/2); % salida del sistema
ERROR = zeros(1,(length(signal)-NTAPS-1)/2);

%% Ecualizacion
if debug == 1
    figure
    hold on
    grid on
    plot(downsample(real(signal),Nos),'.')
end

for n=1:length(signal)-NTAPS-1
    
    % ingresa un elemento al buffer
    Xbuffer = [Xbuffer(2:end);signal(n)];
    
    % convolucion - filtering
    yeq = W*Xbuffer; % multiplicacion matricial, buffer*coef
    
    if mod(n,Nos) == 0
        % Downsample
        % paso por el slicer y calculo el error
        m = m + 1;
        EQ_OUT(m) = yeq;
        SLICER_OUT(m) = slicer(yeq,a);
        ek =  SLICER_OUT(m) - yeq;
        ERROR(m) = ek;
        % gradiente estocastico ek*conj(rk)
        grad = ek.*Xbuffer';
    else
        % Upsample
        ek = 0;
        grad = 0;
    end
       
    % calculo los nuevos coeficientes
    W = W*(1-leak_const)+Beta*grad;
    
    % Para los plots en tiempo real
    if debug == 1 && mod(n,refresh_rate) == 0
        figure(3)
        plot(real(EQ_OUT(1:end)),'.')
        grid on
    end
end
%% Module Output
odata.FSE_coefficients = W;     % eq. coefficients
odata.EQ_OUT = EQ_OUT;          % eq. output
odata.SLICER_OUT = SLICER_OUT;  % symbols detected
odata.ERROR = ERROR;            % error evolution


end

