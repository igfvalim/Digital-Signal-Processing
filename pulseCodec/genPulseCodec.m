clear all;

% especificações do RRC FIR Filter
Fs  = 16000;    % Taxa de amostragem
Ts  = 1/Fs;     % Per�odo de repeti��o dos pulsos
Rs  = 4000;     % Taxa de transmiss�o de s�mbolos
sps = Fs/Rs;    % amostras por s�mbolo
r   = 0.22;     % Fator de holl-off
ntaps = 10* sps + 1;   % Dura��o de 8 s�mbolos

% contadores
cont = 0;               % contador de amostras
cont1 = 0;               % contador de amostras temporário

% abertura de arquivo text .dat
fid = fopen('inputSignal.dat', 'w'); %cria o arquivo inputSignal.dat para escrita

% Gera um trem de pulsos unitários Return-to-Zero (RZ)
for i = 0: (sps -1)

    cont = cont+1;
  cont1 = cont1 + 1;
  if ( cont1 != sps/2 +1)
   pulse(cont) = 0;       % Define valor 0 para o pulso.
  else
   pulse(cont) = 1;      % Define valor 0 para o pulso.
  endif;
  if cont1 == round((4*sps))
      cont1 = 0;
  endif


  temp = round((2^7*0.5*(0.8*pulse(cont)+0.25*pulse(cont)))+2^7+1);   % Amostra o trem de pulsos unitários com resolução de 8-bits.

  address = dec2bin(i,8);                                      % converte para uma palavra binaria de 8 bits o endereço da memória
  saida = dec2bin(temp,8);                                      % converte os coeficientes do pulso para uma palavra binaria de 8 bits
  fprintf(fid,'\r\n%s,',saida);
  %fprintf(fid,'\r\n        when "%s" => data_out_rom_Q <= "%s";', address,saida);  % escreve no arquivo inputSignal.dat
  x(cont) = temp/256;                                    % normalizado entre 0 at� 255 correspondendo aos niveis de um conversor AD de 8 bits

endfor;
fclose(fid);                                                    % fecha o arquivo inputSignal.m

%gera o grafico da entrada para visualiza��o no Octave
figure 1;
subplot(2,1,1)
plot(x);
grid on
subplot(2,1,2)
stem(pulse);



