function out = AGC(x,target)
%AGC Automatic Gain Control module
% x         = received signal
% target    = Desvio Estandar Target

desvio = std(x);
out = x * target/desvio;

end

