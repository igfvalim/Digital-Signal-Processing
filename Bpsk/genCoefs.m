clear all;
pkg load signal;  % Octave needs this; MatLab doesn't

Fs = 16000;  % sample rate
Rs = 4000;    % symbol rate
sps = Fs/Rs; % samples per symbol
%
% Root raised cosine pulse filter
% https://www.michael-joost.de/rrcfilter.pdf
%
r = 0.22; % bandwidth factor
ntaps = 10 * sps + 1; % Pulse duration is 8 symbols

st = [-floor(ntaps/2):floor(ntaps/2)] / sps; % symbol time = t/Ts values
hpulse = 1/sqrt(sps) * (sin ((1-r)*pi*st) + 4*r*st.*cos((1+r)*pi*st)) ./ (pi*st.*(1-(4*r*st).^2));

% fix the removable singularities
hpulse(ceil(ntaps/2)) = 1/sqrt(sps) * (1 - r + 4*r/pi); % t = 0 singulatiry
sing_idx = find(abs(1-(4*r*st).^2) < 0.000001);
for k = [1:length(sing_idx)]
    hpulse(sing_idx) = 1/sqrt(sps) * r/sqrt(2) * ((1+2/pi)*sin(pi/(4*r))+(1-2/pi)*cos(pi/(4*r)));
endfor

% normalize to 0 dB gain
hpulse = hpulse / sum(hpulse);

%[h,w] = freqz(b,a,n) calculate the frequency response.
%The frequency vector w has length n and has values ranging from 0 to ?
%radians per sample. b->polynomial numerator, a->polynomial denominator
[H, w] = freqz(hpulse, 1, 1000);%calcula a resposta em frequencia da entrada ao impulso ( 1000 pontos == pi)
mag = abs(H);%valor absoluto (linear)
db = 20*log10((mag + eps)/(max(mag)));%%valor relativo a banda de passagem( 0 dB) em dB.
pha = angle(H);%resposta em fase

x=0:1/1000:1-1/1000;%normalizando para 0 até 1.

figure(1)
stem(hpulse);%%resposta impulsiva do filtro FIR
%title('Impulse Respónse')
ylabel('coefficient value','FontSize', 16)
xlabel ('n (sequence domain)','FontSize', 16)
figure(2)
plot(x,db);%%resposta em frequencia ( magnitude)
ylabel('magnitude (dB)','FontSize', 16 )
xlabel('normalized frequency','FontSize', 16)
figure(3)
plot(x,pha);%%resposta em frequencia (fase)
ylabel('phase (Rad)','FontSize', 16 )
xlabel('normalized frequency','FontSize', 16)

grid on;

%gera um arquivo de saida com os valores dos coeficientes para 
%serem inseridos manualmente no codigo VHDL do filtro FIR (FirDesign.vhd)
fid = fopen('coefs.dat', 'w');

for n=1:ntaps
  
  saida = num2str(hpulse(n));
  fprintf(fid,'%s\r\n', saida);  
end  
fclose(fid);






