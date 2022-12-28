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
a = [unique(real(symbols)); unique(imag(symbols))]; % parte real e imag de simbolos

%% FSE

Xbuffer = zeros(NTAPS,1);           % Buffer del ecualizador
W = zeros(1,NTAPS);                 % Coeficientes
W((NTAPS+1)/2) = 1;                 % Inicializando un valor
m = 0;

% CMA
CMA_R = sqrt(mean(signal.^4)/mean(signal.^4));  % CMA ref value

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

        if CMA_timer > 0
            % CMA ERROR + FCR OFF
            CMA_timer = CMA_timer - 1;
            ek = -yeq * (abs(yeq) - CMA_R);
            SLICER_OUT(m) = slicer(yeq,a);


        elseif CMA_FCR_timer > 0
            % CMA ERROR + FCR ON
            CMA_FCR_timer = CMA_FCR_timer - 1;
            ek = -yeq * (abs(yeq) - CMA_R);
            
            % FCR
            phase_out(m) = FCR_Buffer(1);   % salida de fase
            rot = exp(-1j*phase_out(m));    % rotador
            y_fcr = yeq*rot;                % salida rotada
            EQ_OUT(m) = y_fcr;

            SLICER_OUT(m) = slicer(y_fcr,a);
            % phase detector
            phase_error = asin(imag(y_fcr*conj(SLICER_OUT(m)))/abs(SLICER_OUT(m))^2); 
            % loop filter
            error_p = Kp*phase_error;           % error proporcional
            error_i = error_i + phase_error*Ki; % error integral
            error_total = error_p + error_i;    % error total
            % NCO
            theta_out = theta_out + error_total;% fase de salida
            % Feedback
            FCR_Buffer = [FCR_Buffer(2:end),theta_out];
        else  
            % DD ERROR + FCR ON
            % FCR
            phase_out(m) = FCR_Buffer(1);   % salida de fase
            rot = exp(-1j*phase_out(m));    % rotador
            y_fcr = yeq*rot;                % salida rotada
            EQ_OUT(m) = y_fcr;

            SLICER_OUT(m) = slicer(y_fcr,a);
            % phase detector
            phase_error = asin(imag(y_fcr*conj(SLICER_OUT(m)))/abs(SLICER_OUT(m))^2); 
            % loop filter
            error_p = Kp*phase_error;           % error proporcional
            error_i = error_i + phase_error*Ki; % error integral
            error_total = error_p + error_i;    % error total
            % NCO
            theta_out = theta_out + error_total;% fase de salida
            % Feedback
            FCR_Buffer = [FCR_Buffer(2:end),theta_out];
            
            ek =  SLICER_OUT(m) - y_fcr;
            ek = ek * rot^-1;
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
        plot(real(EQ_OUT(m-450:m)),imag(EQ_OUT(m-450:m)),'.')
        grid on
        title("Live Constelation FSE OUT")
        xlim([-2 2])
        ylim([-2 2])
    end
end

%% Module Output
odata.FSE_coefficients = W;     % eq. coefficients
odata.EQ_OUT = EQ_OUT;          % eq. output
odata.SLICER_OUT = SLICER_OUT;  % symbols detected
odata.ERROR = ERROR;            % error evolution


end

