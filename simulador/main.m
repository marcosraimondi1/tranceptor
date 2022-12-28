function [odata] = main(config,bits)
%   main; full tranceptor simulator
%   Parameters: config struct
%   config.M;           % orden de simulacion
%   config.NOSF;     % tasa de sobremuestreo
%   config.span;     % cantidad de simbolos a generar con el filtro
%   config.BR;         % baud rate
%   config.rolloff;  
%   config.EbNo;     % Energy bit / Noise power density [db]
%   config.NFFT;
%   crop_percentage = config.crop_percentage; 
% 
    %% Parameters
    M = config.M;           % orden de simulacion
    NOSF = config.NOSF;     % tasa de sobremuestreo
    span = config.span;     % cantidad de simbolos a generar con el filtro
    BR = config.BR;         % baud rate
    rolloff = config.rolloff;  
    EbNo = config.EbNo;     % Energy bit / Noise power density [db]
    NFFT = config.NFFT;
    agc_target = config.agc_target;
    crop_percentage = config.crop_percentage;
    
    
    %% TX
    % config
    filter_kernel = rcosdesign(rolloff, span, NOSF, 'sqrt');
    
    tx_config.M = M;  
    tx_config.NFFT = NFFT;
    tx_config.BR = BR;
    tx_config.bits = bits;
    tx_config.NOSF = NOSF;
    tx_config.debug = config.debug;
    tx_config.filter_kernel = filter_kernel;
    % output
    tx_odata = tx_qam_M(tx_config);
    
    
    %% Channel
    % config
    ch_config.select_orden = config.select_orden;
    ch_config.fc = config.channelDigitalFc;
    ch_config.N = config.channelNTaps;
    ch_config.M = M;
    ch_config.NOSF = NOSF;
    ch_config.signal = tx_odata.out;
    ch_config.EbNo = EbNo;
    ch_config.debug = config.debug;
    
    % output
    ch_odata = channel(ch_config);

    %% RX
    % FSE config
    FSE_config.NTAPS = config.FSENTaps;
    FSE_config.NFFT = NFFT;
    FSE_config.leak_const = config.leak_const;
    FSE_config.Beta = config.learning_step;
    FSE_config.Nos = config.NOSF;
    FSE_config.M = config.M;
    FSE_config.refresh_rate = config.refresh_rate;
    FSE_config.debug = config.debug;
    
    % RX config
    rx_config.FSE_config = FSE_config;
    rx_config.NFFT = NFFT;
    rx_config.BR = BR;
    rx_config.r = ch_odata.out;
    rx_config.x_mod = tx_odata.x_mod;    
    rx_config.agc_target = agc_target; 
    rx_config.M = M;
    rx_config.NOSF = NOSF;
    rx_config.filter_kernel = filter_kernel;
    rx_config.debug = config.debug;
    % output
    rx_odata = rx_qam_M(rx_config);
    
    
    %% BER
    ber_config.bitsIn = tx_odata.bitsIn;
    ber_config.bitsOut = rx_odata.bitsOut;
    ber_config.crop_percentage = crop_percentage;
    ber_odata = ber_checker(ber_config);
    
    %% OUTPUT
    odata = ber_odata;

end

