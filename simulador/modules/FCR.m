function [y_fcr, rot, theta_out,error_i, slicer_out]  = FCR(yeq,phase_out,theta_prev,error_i_prev,Kp,Ki,a)
%FCR - Fine Carrier Recovery
%
% Syntax: output = FCR(input)
%
    rot = exp(-1j*phase_out);    % rotador
    y_fcr = yeq*rot;             % salida rotada

    slicer_out = slicer(y_fcr,a);
    % phase detector
    phase_error = asin(imag(y_fcr*conj(slicer_out))/abs(slicer_out)^2); 

    % loop filter
    error_p = Kp*phase_error;           % error proporcional
    error_i = error_i_prev + phase_error*Ki; % error integral
    error_total = error_p + error_i;    % error total
    % NCO
    theta_out = theta_prev + error_total;% fase de salida

end