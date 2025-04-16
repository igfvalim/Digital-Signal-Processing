----------------------- MULTIPLEXADOR DE 8-BITS SINCRONIZADO --------------------------------
---- multiplexador acionado por um enable que converte um um barramento serial de 8-bits ----
---- em um bitstream sincronizado em 8 ciclos de clock.					 ----
---------------------------------------------------------------------------------------------

-- DECLARAÇÃO DE BIBLIOTECAS
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;   -- TRABALHA VALORES LÓGICOS DIGITAIS
USE IEEE.std_logic_arith.ALL;  -- TRABALHA COM ARITMÉTICA

ENTITY mux8 IS
  
PORT(

      clock          : IN STD_LOGIC;
      enable_mux8    : IN  STD_LOGIC_VECTOR(0 DOWNTO 0); -- ACIONAMENTO DO CODIFICADOR DE 8-BITS
      address_mux8   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- SELETOR DO CODIFICADOR DE 8-BITS
      sinal_in_mux8  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); -- SINAL DE ENTRADA "PALAVRA DE 8-BITS"
      sinal_out_mux8 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)  -- SINAL DE SAÍDA "BITSTREAM"
   
     );

END mux8;

ARCHITECTURE rtl OF mux8 IS

-- SINAIS INTERNOS GLOBAIS
SIGNAL sinal_i : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL sinal_o : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL address : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

-- ATRIBUIÇÃO DE VALORES DE ENTRADA 
sinal_i <= sinal_in_mux8;
address <= enable_mux8(0)&address_mux8(2)&address_mux8(1)&address_mux8(0);

-- MULTIPLEXADOR DE 8-BITS
WITH address SELECT

sinal_o(0) <= sinal_i(0) WHEN "1000",
              sinal_i(1) WHEN "1001",
              sinal_i(2) WHEN "1010",
              sinal_i(3) WHEN "1011",
              sinal_i(4) WHEN "1100",
              sinal_i(5) WHEN "1101",
              sinal_i(6) WHEN "1110",
              sinal_i(7) WHEN "1111",
              'U' WHEN OTHERS;

-- CASAMENTO DE TIMING DAS INSTRUÇÕES E ATRIBUIÇÃO DA SAÍDA
PROCESS(clock)
BEGIN

	IF rising_edge(clock) THEN
		IF (enable_mux8 = "1") THEN

		       sinal_out_mux8  <= sinal_o;

		END IF;
	END IF;

END PROCESS;

END rtl;