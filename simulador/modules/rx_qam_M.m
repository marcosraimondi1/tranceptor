function [odata] = rx_qam_M(config)
    %RX_QAM_M ; qam_M receptor
    %   Parameters: config struct
    %   - config.M : modulation order
    %   - config.x_mod : tx modulated signal
    %   - config.r : received signal
    %   - config.NOSF : oversampling factor
    %   - config.filter_kernel : pulse shape filter
    %   - config.crop_percentage
    %   - config.bitsIn : bits sent from tx
    %   - config.debug : 1 to see plots
    %   
    %   Output: odata struct
    %   - odata.symbols : transmited symbols (no over sampling) 
    %   - odata.out : modulated and shaped symbols
    %% Parameters
    FSE_config = config.FSE_config;
    NFFT = config.NFFT;
    BR = config.BR;
    M = config.M;
    k = log2(M);
    x_mod = config.x_mod;
    NOSF = config.NOSF;
    r = config.r;
    agc_target = config.agc_target;
    filter_kernel = config.filter_kernel;

    %% AGC
    agc_out = AGC(r,agc_target);  
    %% ANTES 
%     symbols = qammod(0:M-1,M);          % posibles simbolos a detectar
%     a = {unique(real(symbols)); unique(imag(symbols))}; % parte real e imag de simbolos
    %MF
%     mf = flip(conj(filter_kernel));
%     y = filter(mf,1,r);
    % Decimation - muestreo cada kT
%     yk = downsample(y,NOSF); % se queda con una muestra y descarta NOSF muestras
    % Slicer
%     ak = slicer(yk, a);

    %% FSE
    FSE_config.signal = agc_out;
    FSE_odata = FSE(FSE_config);
    ak = FSE_odata.SLICER_OUT;
    yk = FSE_odata.EQ_OUT;
    
    %% Delay fix
    delay = finddelay(x_mod, ak); % cuantos simbolos esta atrasado ak respecto de x_mod
    ak = ak(1+delay:end);

    %% M-AM Demapper
    dataSymbolsOut = qamdemod(ak, M);
    dataOutMatrix = de2bi(dataSymbolsOut).';
    bitsOut = dataOutMatrix(:);

    %% Output
    odata.bitsOut = bitsOut;
    odata.ERROR_I = FSE_odata.ERROR_I;
    
    %% PLOTS
    if config.debug == 1
        
        % PSDs
        Fs = NOSF*BR;
        % entrada del FSE
        [pyy, fyy] = pwelch(agc_out, hanning(NFFT/2), [], NFFT,Fs,'centered');
        % salida del FSE
        [pxx, fxx] = pwelch(yk, hanning(NFFT/2), [], NFFT,Fs,'centered');
       
        figure
        grid on
        hold on
        title("PSDs Comparison")
        plot(fxx,pxx, 'LineWidth',1)
        plot(fyy,pyy, 'LineWidth',1)
        
        legend("FSE output", "FSE input")
        
        % Diagrama de constelacion
        figure
        sgtitle("Constelacion")
        subplot 211
        title("FSE OUT")
        hold on
        grid on
        plot(real(yk(500:end)), imag(yk(500:end)), '.', 'LineWidth', 2)
        plot(real(x_mod), imag(x_mod), 'o', 'LineWidth', 2)
        xlabel("Re")
        ylabel("Im")
        xlim([-k-1 k+1])
        ylim([-k-1 k+1])
        
        % Diagrama de constelacion
        subplot 212
        title("FSE IN")
        hold on
        grid on
        plot(real(agc_out(500:end)), imag(agc_out(500:end)), '.', 'LineWidth', 2)
        plot(real(x_mod), imag(x_mod), 'o', 'LineWidth', 2)
        xlabel("Re")
        ylabel("Im")
        xlim([-k-1 k+1])
        ylim([-k-1 k+1])
        
        % Histogramas
        nbins = 100;
        
        figure
        sgtitle("Histogramas")
        subplot 221
        hold on
        grid on
        title("RE-FSE OUT-")
        histogram(real(yk(500:end)),nbins)
        
        subplot 222
        hold on
        grid on
        title("IM-FSE OUT-")
        histogram(imag(yk(500:end)),nbins)
        
        
        % Histogramas
        subplot 223
        hold on
        grid on
        title("RE-FSE IN-")
        histogram(real(agc_out(500:end)),nbins)
        
        subplot 224
        hold on
        grid on
        title("IM{FSE IN}")
        histogram(imag(agc_out(500:end)),nbins)
        
    end
    
    
end

