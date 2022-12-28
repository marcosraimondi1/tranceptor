function [odata] = channel(config)
    %	CHANNEL , channel with AWGN simulator
    %   Parameters: config struct
    %   - config.M : modulation order
    %   - config.NOSF : oversampling factor
    %   - config.signal
    %   - config.EbNo : Energy bit / Noise power density [db]
    %   - config.debug : 1 to see plots
    %   - config.N : channel filter TAPS
    %   - config.fc : frecuencia de corte del canal
    %   - config.select_orden : = 1 -> limitacion del canal despues del ruido
    %   Output: odata struct
    %   - odata.SNR : SNR
    %   - odata.out : signal with AWGN
    %% Parameters
    M = config.M;
    BR = config.BR;
    NOSF = config.NOSF;
    select_orden = config.select_orden;
    NTAPS = config.N;
    fc = config.fc;
    EbNo = config.EbNo;
    p = config.signal;
    k = log2(M);
    carrier_error = config.carrier_error;
    
    %% Noise Generator 
    % 1) SNR
    SNR_db = EbNo - 10*log10(NOSF) + 10*log10(k);

    % 2) SNR en veces
    SNR = 10^(SNR_db/10);

    % 3) Varianza del Ruido
    Ptx = var(p);
    N = Ptx/SNR; % sigma^2

    % 4) ruido, varianza dividida por dos por la parte real e imaginaria
    sigma = sqrt(N/2);
    noise = sigma*randn(length(p),1) + 1j*sigma*randn(length(p),1);

    r_noise = p + noise;
    
    %% ISI
    % ISI
    % rta del canal
    if fc == 1
        % canal pasa todo
        b = 1;
    else
        b = fir1(NTAPS,fc);
    end
    
    % limitacion del canal despues del ruido
    r_out1 = filter(b,1,r_noise);
    
    % limitacion del canal antes del ruido
    r_out2 = filter(b,1,p) + noise;
    
    %% 
    if select_orden == 1
        noise_out = r_out1;
    else
        noise_out = r_out2;
    end

    %% Carrier Error
    if config.carrier_error_type == "frequency"    
        t = (0:length(p)-1)*1/BR;
        rot = exp(1j*2*pi*carrier_error*t);
    else
        rot = exp(1j*carrier_error);
    end
    
    out = noise_out .* rot.';

    %% PLOTS
    if config.debug == 1
        figure
        title("Channel")
        hold on
        grid on
        [pxx,fxx] = pwelch(p, hanning(512), [],1024,'centered');
        [pyy,fyy] = pwelch(out,hanning(512), [],1024,'centered');
        
        plot(fxx,pxx,'Linewidth',2)
        plot(fyy,pyy,'Linewidth',2)
        
        legend("Channel In","Channel Out")
        % Freq Response
        figure
        hold on
        grid on
        freqz(b,1,512)
        title("Channel Freq. Response")
    end

    %% OUTPUT
    odata.out = out;
    odata.SNR = SNR;
end

