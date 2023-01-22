function [odata] = main(config,bits)
%   main; full tranceptor simulator
%   Parameters: config struct
% "simulator":{
%       "NFFT":1024,
%       "transmisor" : {
%          "M":4,
%          "NOSF":2,
%          "span":20,
%          "BR":16e9,
%          "rolloff":0.2,
%          "debug":0
%       },
%       "channel" : {
%          "channelDigitalFc": 0.8,
%          "channelNTaps": 4,
%          "select_orden": 1,
%          "EbNo":5,
%          "debug":0
%       },
%       "receptor": {
%          "FSE":{
%             "NTAPS": 101,
%             "leak_const": 2.5e-7,
%             "refresh_rate": 1000,
%             "learning_step": 0.5e-3,
%             "debug": 0
%          },
%          "agc_target": 1,
%          "crop_percentage":50,
%          "debug":0
%       }
%    }
%   odata = [cantidad de errores, cantidad de bits, error integral]

    %% TX
    % config
    tx_config = config.transmisor;
    filter_kernel = rcosdesign(tx_config.rolloff, tx_config.span, tx_config.NOSF, 'sqrt');
    tx_config.bits = bits;
    tx_config.NFFT = config.NFFT;
    tx_config.filter_kernel = filter_kernel;

    % output
    tx_odata = tx_qam_M(tx_config);
    
    %% Channel
    % config
    ch_config = config.channel;
    ch_config.BR = tx_config.BR;
    ch_config.M = tx_config.M;
    ch_config.NOSF = tx_config.NOSF;
    ch_config.signal = tx_odata.out;
    
    % output
    ch_odata = channel(ch_config);

    %% RX
    % FSE config
    FSE_config = config.receptor.FSE;
    FSE_config.NFFT = config.NFFT;
    FSE_config.Nos = tx_config.NOSF;
    FSE_config.M = tx_config.M;
    
    % RX config
    rx_config = config.receptor;
    rx_config.FSE_config = FSE_config;
    rx_config.NFFT = config.NFFT;
    rx_config.BR = tx_config.BR;
    rx_config.r = ch_odata.out;
    rx_config.x_mod = tx_odata.x_mod;    
    rx_config.M = tx_config.M;
    rx_config.NOSF = tx_config.NOSF;
    rx_config.filter_kernel = filter_kernel;

    % output
    rx_odata = rx_qam_M(rx_config);
    
    %% BER
    ber_config.bitsIn = tx_odata.bitsIn;
    ber_config.bitsOut = rx_odata.bitsOut;
    ber_config.crop_percentage = rx_config.crop_percentage;
    ber_odata = ber_checker(ber_config);
    
    %% OUTPUT
    odata = ber_odata;
    odata.rx = rx_odata;
end

