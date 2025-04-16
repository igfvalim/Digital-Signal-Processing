clear all;
Fs  = 16000;    % Taxa de amostragem
Ts  = 1/Fs;     % Per�odo de repeti��o dos pulsos
Rs  = 4000;     % Taxa de transmiss�o de s�mbolos
sps = Fs/Rs;    % amostras por s�mbolo
r   = 0.22;     % Fator de holl-off

ntaps = 10* sps + 1;   % Dura��o de 8 s�mbolos
cont = 0;               % contador de amostras
cont1 = 0;
fid = fopen('inputSignal.dat', 'w'); %cria o arquivo inputSignal.m

for i = 0: 20*(sps -1)   % Gerar 41 amostras em um espa�o de banda de 82 amostras

    cont = cont+1;      % Contagem de amostras por per�odo Ts para B = T/2 , onde B = 41 amostras
  cont1 = cont1 + 1;
  if ( cont1 != sps/2 +1)    % Gera valores de um trem de 82 pulsos unit�rios em um intervalo de banda 2 x maior que a de Nyquist
   pulse(cont) = 0;       % Define valor 1 ou 0 para o pulso.
  else
   pulse(cont) = 1;
  endif;
  if cont1 == round((4*sps))
      cont1 = 0;
  endif


  temp = round((2^7*0.5*(0.8*pulse(cont)+0.25*pulse(cont)))+2^7+1);   % cria um trem de pulsos unit�rios
                                                                % normalizado entre 0 at� 255 correspondendo aos niveis do conversor AD de 8 bits
  address = dec2bin(i,8);
  saida = dec2bin(temp,8);                                      % converte para uma palavra binaria de 8 bits
 %fprintf(fid,'\r\n        when "%s" => data_out_rom_Q <= "%s";', address,saida);                                 % escreve no arquivo inputSignal.dat
 fprintf(fid,'\r\n%s',saida);
  x(cont) = temp/256;

endfor;
fclose(fid);                                                    % fecha o arquivo inputSignal.m

%gera o grafico da entrada para visualiza��o no Octave
figure 1;
subplot(2,1,1)
plot(x);
grid on
subplot(2,1,2)
stem(pulse);



