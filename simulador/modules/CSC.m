function out = CSC(config)
% CSC - Cycle Slip Correction
    tx = config.tx;
    rx = config.rx;
    umbral = config.umbral;
    debug = config.debug;
    
    tx_i = real(tx);
    tx_q = imag(tx);
    
    rx_i = real(rx);
    rx_q = imag(rx);

    %% CORRELATION MATRIX
    m11 = xcorr(tx_i,rx_i);
    m12 = xcorr(tx_i,rx_q);
    m21 = xcorr(tx_q,rx_i);
    m22 = xcorr(tx_q,rx_q);

    %% PLOTS
    if debug == 1
        figure
        sgtitle("Correlation Matrix")
        subplot 221
        hold on
        title("RX I")
        ylabel("TX I")
        plot(m11), grid on, grid minor
        subplot 222
        hold on
        title("RX Q")
        plot(m12), grid on, grid minor
        subplot 223
        hold on
        ylabel("TX Q")
        plot(m21), grid on, grid minor
        subplot 224
        hold on
        plot(m22), grid on, grid minor
    end
    %%
    if supera_umbral(abs(m11), umbral)
        % 0 o 180
        if supera_umbral(m22, umbral)
            % 0
            phase_correction = 0;
        else
            % 180
            phase_correction = pi;
        end
    else
        % 90 o 270
        if supera_umbral(m12, umbral)
            % 90
            phase_correction = pi/2;
        else
            % 270
            phase_correction = 3*pi/2;
        end
    end

    out = rx*exp(-1j*phase_correction);

    

    %% PLOTS
    if debug == 1
        %% CORRELATION MATRIX AFTER
        m11 = xcorr(tx_i,real(out));
        m12 = xcorr(tx_i,imag(out));
        m21 = xcorr(tx_q,real(out));
        m22 = xcorr(tx_q,imag(out));
        figure
        sgtitle("Correlation Matrix (corrected)")
        subplot 221
        hold on
        title("RX I")
        ylabel("TX I")
        plot(m11), grid on, grid minor
        subplot 222
        hold on
        title("RX Q")
        plot(m12), grid on, grid minor
        subplot 223
        hold on
        ylabel("TX Q")
        plot(m21), grid on, grid minor
        subplot 224
        hold on
        plot(m22), grid on, grid minor
    end

end

function out = supera_umbral(x,umbral)
    out = max(x) > umbral;
end