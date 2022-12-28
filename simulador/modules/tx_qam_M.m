function [odata] = tx_qam_M(config)
    %	TRANS_QAM_M , qam_M transmisor simulation
    %   Parameters: config struct
    %   - config.M : modulation order
    %   - config.BR : baud rate
    %   - config.bits : bits to transmit 
    %   - config.NOSF : oversampling factor
    %   - config.filter_kernel : pulse shape filter
    %   - config.NFFT
    %   - config.debug : 1 to see plots
    %   
    %   Output: odata struct
    %   - odata.symbols : transmited symbols (no over sampling) 
    %   - odata.out : modulated and shaped symbols
    %   - odata.x_mod
    %   - odata.bitsIn

    %% Parameters
    NFFT = config.NFFT;
    BR = config.BR;
    M = config.M;
    bits = config.bits;
    NOSF = config.NOSF;
    filter_kernel = config.filter_kernel;

    %% M-AM Mapper
    k = log2(M);                    % bits por simbolo
    symbols = fix(length(bits)/k);  % cantidad de simbolos 
    bitsIn = bits(1:symbols*k); % recortar bits extras que no entran en la sim
    dataInMatrix = reshape(bitsIn, k, symbols).'; % 1 fila de bits = 1 simbolo
    dataSymbolsIn = bi2de(dataInMatrix);  % cada fila a decimal
    x_mod = qammod(dataSymbolsIn,M);      % modulacion quam

    %% Upsample
    x_up = upsample(x_mod, NOSF);

    %% Transmitter filter
    p = filter(filter_kernel,1,x_up);
    
    %% OUTPUT
    odata.symbols = symbols;
    odata.out = p;
    odata.x_mod = x_mod;
    odata.bitsIn = bitsIn;
    
    %% PLOTS
    if config.debug == 1
        % DIAGRAMA DE OJO SALIDA DEL FILTRO
        eyediagram(real(p),8);

        % PSDs
        Fs = NOSF*BR;
        % entrada al filtro
        [pyy, fyy] = pwelch(x_up, hanning(NFFT/2), [], NFFT,Fs,'centered');
        % salida tx
        [pxx, fxx] = pwelch(p, hanning(NFFT/2), [], NFFT,Fs,'centered');
        % filter psd
        H_abs = abs(fftshift(fft(filter_kernel, NFFT))).^2;
        factor = max(abs(pxx)); % scaling factor
        figure
        grid on
        hold on
        title("PSDs Comparison")
        plot(fxx,pxx/factor, 'LineWidth',1)
        plot(fyy,pyy/factor, 'LineWidth',1)
        plot(fyy,H_abs/max(abs(H_abs)), 'LineWidth',1)
        legend("ps output", "ps input", "|H_f_i_l_t_e_r|^2")
    end
    
    
    
end

