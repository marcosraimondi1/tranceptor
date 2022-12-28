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

%% PARAMETERS

NTAPS         = config.NTAPS;
NFFT          = config.NFFT;
leak_const    = config.leak_const;
Beta          = config.learning_step;
Nos           = config.Nos;
M             = config.M;
refresh_rate  = config.refresh_rate;
debug         = config.debug;
signal        = config.signal;
CMA_timer     = config.CMA_timer;
CMA_FCR_timer = config.CMA_FCR_timer;
Kp            = config.Kp;      % ganancia proporcional
Ki            = config.Ki;      % ganancia integral
L             = config.L;       % delay de realimentacion

symbols = qammod(0:M-1,M);                          % posibles simbolos a detectar
a = {unique(real(symbols)); unique(imag(symbols))}; % parte real e imag de simbolos
CMA_R = sqrt(mean(abs(symbols).^4)/mean(abs(symbols).^2));    % CMA ref value
max_real = max(a{1});
max_imag = max(a{2});

%% FSE

Xbuffer = zeros(NTAPS,1);           % Buffer del ecualizador
W = zeros(1,NTAPS);                 % Coeficientes
W((NTAPS+1)/2) = 1;                 % Inicializando un valor
m = 0;

% FCR
FCR_Buffer = zeros(1,L);        % buffer de realimentacion 
error_i = 0;
theta_out = 0;

%% LOGS
Lsim_downsample = (length(signal)-NTAPS-1)/2;
PHASE_OUT = zeros(1,Lsim_downsample);  % fase recuperada
EQ_OUT = zeros(1,Lsim_downsample);     % salida ecualizador 
SLICER_OUT = zeros(1,Lsim_downsample); % salida del sistema
ERROR = zeros(1,Lsim_downsample);      % salida de error


%% Ecualizacion

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

        if CMA_timer < 0
            % FCR
            phase_out(m) = FCR_Buffer(1);   % salida de fase
            
            [y_fcr, rot, theta_out, error_i, slicer_out] = FCR(yeq,phase_out(m),theta_out,error_i,Kp,Ki,a);

            % Feedback
            FCR_Buffer = [FCR_Buffer(2:end),theta_out];
            
            EQ_OUT(m) = y_fcr;
            SLICER_OUT(m) = slicer_out;

            if CMA_FCR_timer < 0
                % DD ERROR + FCR ON
                ek =  SLICER_OUT(m) - y_fcr;
                ek = ek * rot^-1;
            else
                % CMA ERROR + FCR ON
                CMA_FCR_timer = CMA_FCR_timer - 1;
                ek = -yeq * (abs(yeq) - CMA_R);
            end

        else
            % CMA ERROR + FCR OFF
            CMA_timer = CMA_timer - 1;
            ek = -yeq * (abs(yeq) - CMA_R);
            SLICER_OUT(m) = slicer(yeq,a);
        end
        
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
        % plot(real(EQ_OUT(1:end)), '.')
        plot(real(EQ_OUT(m-450:m)),imag(EQ_OUT(m-450:m)),'.')
        grid on
        title("Live Constelation FSE OUT")
        xlim([-max_real-1 max_real+1])
        ylim([-max_imag-1 max_imag+1])
        
    end
end
if debug == 1
    C = fftshift(fft(W,NFFT));      % FFEq
    
    % Circunferencia: r^2 = x^2 + y^2
    x = linspace(-CMA_R, CMA_R, 100);
    y = sqrt(CMA_R^2 - x.^2);
    
    figure
    title("Referencia CMA")
    grid on
    hold on
    plot(real(symbols), imag(symbols), 'x', 'markersize',15, 'linewidth',5)
    plot(x,y, '--r', 'linewidth',2)
    plot(x,-y, '--r', 'linewidth',2)
    legend("Tx symbols", "CMA Ref")
    
    figure
    hold on
    title('Eq Freq Response')
    plot(abs(C), '--m','linewidth',2)
    grid on

    figure
    hold on
    title('Error Evolution')
    plot(abs(ERROR))
    grid on


end
%% Module Output
odata.FSE_coefficients = W;     % eq. coefficients
odata.EQ_OUT = EQ_OUT;          % eq. output
odata.SLICER_OUT = SLICER_OUT;  % symbols detected
odata.ERROR = ERROR;            % error evolution


end

