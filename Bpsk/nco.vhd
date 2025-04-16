------------------     NUMERICALLY CONTROLLED OSCILLATOR     -------------------------------------------------------------
---- NCO senoidal acionado por um enable, entrega um senóide de 21 coeficientes sincronizado em 21 ciclos de clock.   ----
--------------------------------------------------------------------------------------------------------------------------
---- ntaps / 2 = N coeficientes senóide (Ciclo de senóide )                                                           ----
--------------------------------------------------------------------------------------------------------------------------
---- Coeficientes do senóide obtidos à partir do arquivo nco.dat gerado pelo código genNco.m                          ---- 
--------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;   -- TRABALHA VALORES LÓGICOS.
USE IEEE.std_logic_arith.ALL;  -- TRABALHA COM ARITMÉTICA.
USE IEEE.std_logic_signed.ALL; -- TRABALHA COM COMPLEMENTO DE 2.

ENTITY nco IS
  
  PORT (
        
        clock        : IN  STD_LOGIC;
        enable_nco   : IN  STD_LOGIC;
        address_nco  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        nco          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
                  
       );
  
END nco;

ARCHITECTURE rtl OF nco IS

-- CONSTANTES GLOBAIS
CONSTANT rom_length : INTEGER := 21; -- COMPRIMENTO DA ROM QUE ARMAZENA O SENÓIDE É 21 BYTES. 

-- MEMÓRIA ROM DE UM SENÓIDE (SENO)
TYPE seno IS ARRAY ( INTEGER RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
CONSTANT sin : seno(rom_length-1 DOWNTO 0):=
(
  "10000001", 
  "10010110", 
  "10101000", 
  "10110111", 
  "11000001", 
  "11000100", 
  "11000001", 
  "10110111", 
  "10101000", 
  "10010110", 
  "10000001", 
  "01101100", 
  "01011010", 
  "01001011", 
  "01000001", 
  "00111110", 
  "01000001", 
  "01001011", 
  "01011010", 
  "01101100", 
  "10000001"   
);	

BEGIN
-- CASAMENTO DE TIMING DAS INSTRUÇÕES E ATRIBUIÇÃO DA SAÍDA.
	PROCESS(clock)
		BEGIN
		IF (rising_edge(clock) AND enable_nco = '1') THEN 
			
			IF conv_integer(address_nco) >= 0 AND conv_integer(address_nco) <= rom_length THEN
				nco <= sin(conv_integer(address_nco));
		        ELSE
	            	-- Tratamento de erro ou padr?o, se necess?rio
	            	nco <=  "10000001";
	       		END IF;		

			

		END IF;
	END PROCESS;

END rtl;
