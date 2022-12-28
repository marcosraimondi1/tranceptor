function ak = slicer(yk,a)
%SLICER toma de decision para qamM
% Argumentos: 
%            yk -> symbol input
%            a  -> array con [parte real , parte imag] 
%               ej: para qam4: a = [ [-1 1] ; [-1 1] ]
%   symbols = qammod(0:M-1,M); 
%   a = [unique(real(symbols)), unique(imag(symbols))]

    %%
    

    % umbrales para discernir simbolos parte real
    i = a(1,:);
    dsr = abs(i(1)-i(2))/2; % distancia entre simbolo parte real
    ur = i - dsr;
    
    % umbrales para discernir simbolos parte imag
    q = a(2,:);
    dsi = abs(i(1)-i(2))/2; % distancia entre simbolo parte imag
    ui = q - dsi;
        
    ak = zeros(size(yk));
    
    for n=1:length(yk)
        s_n = yk(n);   % simbolo_n = yk(n)
        
        ak_r = i(1);   % inicializado en el valor mas bajo
        ak_i = q(1);   % inicializado en el valor mas bajo
        
        aux = find(real(s_n) > ur);
        if ~isempty(aux)
            ak_r = i(aux(end));
        end
        
        aux = find(imag(s_n) > ui);
        if ~isempty(aux)
            ak_i = q(aux(end));
        end
        
        ak(n) = ak_r + 1j*ak_i;
    end
end

