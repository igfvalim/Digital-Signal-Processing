-----------------------  CODIFICADOR DE PULSOS SINCRONIZADO  --------------------------------
---- codificador de pulsos sigma delta RZ {+1,-1} selecionado por um enable, entrega um   ----
---- trem de N pulsos sincronizados em N ciclos de clock.			         ----
---------------------------------------------------------------------------------------------
---- Tabela de bytes obtida à partir do arquivo pulse.dat gerado pelo código genPulse.m  ---- 
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;   -- TRABALHA VALORES LÓGICOS DIGITAIS
USE IEEE.std_logic_arith.ALL;  -- TRABALHA COM ARITMÉTICA
USE IEEE.std_logic_signed.ALL; -- TRABALHA COM COMPLEMENTO DE 2.

ENTITY pulseCodec IS
  
  PORT (
        
        clock         : IN  STD_LOGIC;			   -- SIMULA RELÓGIO DE 50MHZ VINDO DO EVALUATION BOARD
        enable_pulse  : IN  STD_LOGIC; 			   -- SELEÇÃO DE CODIFICAÇÃO DE PULSOS
        address_pulse : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  -- ENDEREÇAMENTO DE CODIFICAÇÃO DE PULSOS
        pulse         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)   -- SINAL DE SAÍDA "TREM DE PULSOS"
                     
       );
  
END pulseCodec;

ARCHITECTURE rtl OF pulseCodec IS

-- CONSTANTES GLOBAIS
CONSTANT rom_length : INTEGER := 4; -- COMPRIMENTO DA ROM QUE ARMAZENA OS PULSOS É 4 BYTES. 

-- MEMÓRIA ROM DE UM TREM DE PULSOS POSITIVO {0,0,+1,0}
TYPE pulseROM1 IS ARRAY (INTEGER RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
CONSTANT pulseTrain1 : pulseROM1(rom_length -1 DOWNTO 0) :=
(

	"10000001",
	"10000001",
	"11000100",
	"10000001"

);

-- MEMÓRIA ROM DE UM TREM DE PULSOS NEGATIVO {0,0,-1,0}
TYPE pulseROM0 IS ARRAY (INTEGER RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
CONSTANT pulseTrain0 : pulseROM0(rom_length -1 DOWNTO 0) :=
(

	"10000001",
	"10000001",
	"00111110",
	"10000001"

);

BEGIN

-- CASAMENTO DE TIMING DAS INSTRUÇÕES E ATRIBUIÇÃO DA SAÍDA.
PROCESS(clock)
	BEGIN
	IF rising_edge(clock) AND enable_pulse ='1' THEN -- ATRIBUIÇÃO DE PULSO POSITIVO {+1}

	 	IF conv_integer(address_pulse) >= 0 AND conv_integer(address_pulse) <= rom_length THEN
	            pulse <= pulseTrain1(conv_integer(address_pulse));
	        ELSE
	            -- Tratamento de erro ou padrão, se necessário.
	            pulse <=  "10000001";
	        END IF;
		
	ELSE IF rising_edge(clock) AND enable_pulse ='0' THEN -- ATRIBUIÇÃO DE PULSO NEGATIVO {-1}.

	 	IF conv_integer(address_pulse) >= 0 AND conv_integer(address_pulse) <= rom_length THEN
	            pulse <= pulseTrain0(conv_integer(address_pulse));
	        ELSE
	            -- Tratamento de erro ou padrão, se necessário.
	            pulse <=  "10000001";
	        END IF;
	END IF;	
	END IF;

END PROCESS;   

END rtl;