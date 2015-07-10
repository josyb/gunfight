library ieee;
	use ieee.std_logic_1164.all;

entity tb_contrivedsm is
	end entity tb_contrivedsm;

architecture sim of tb_contrivedsm is

	constant tCK 	: time := 10 ns;
	

	signal Clk      : std_logic ;
	signal Reset    : std_logic ;
	signal A        : std_logic ;
	signal B        : std_logic ;
	signal C        : std_logic ;
	signal u1_DoneP : std_logic ;
	signal u2_DoneP : std_logic ;
	signal u3_DoneP : std_logic ;
	signal u4_DoneP : std_logic ;
	signal u1_Stage	: natural	range 0 to 3 ;
	signal u2_Stage	: natural	range 0 to 3 ;
	signal u3_Stage	: natural	range 0 to 3 ;
	signal u4_Stage	: natural	range 0 to 3 ;
	
	
component contrivedsm
	generic (
		STATE_MACHINE_STYLE		:	string	:= "JOSYB" 	--	"TWOPROCESS" or "SYNCHRONOUS" or "HYBRID" or "HYBRIDJOSYB"
		) ;
	port (
		Clk		:	in	std_logic ;
		Reset	:	in	std_logic ;
		
		A		:	in	std_logic ;
		B		:	in	std_logic ;
		C		:	in	std_logic ;
		
		Stage	:	out	natural	range 0 to 3 ;
		
		DoneP	:	out std_logic
		) ;
	end component ;	
	
begin



	u1 : contrivedsm
		generic map(
			STATE_MACHINE_STYLE => "TWOPROCESS"
			)
		port map(
			Clk   => Clk,
			Reset => Reset,
			A     => A,
			B     => B,
			C     => C,
			Stage => u1_Stage ,
			DoneP => u1_DoneP
		);
	
	u2 : contrivedsm
		generic map(
			STATE_MACHINE_STYLE => "SYNCHRONOUS"
			)
		port map(
			Clk   => Clk,
			Reset => Reset,
			A     => A,
			B     => B,
			C     => C,
			Stage => u2_Stage ,
			DoneP => u2_DoneP
		);
	
	u3 : contrivedsm
		generic map(
			STATE_MACHINE_STYLE => "HYBRID"
			)
		port map(
			Clk   => Clk,
			Reset => Reset,
			A     => A,
			B     => B,
			C     => C,
			Stage => u3_Stage ,
			DoneP => u3_DoneP
		);
	
	u4 : contrivedsm
		generic map(
			STATE_MACHINE_STYLE => "HYBRIDJOSYB"
			)
		port map(
			Clk   => Clk,
			Reset => Reset,
			A     => A,
			B     => B,
			C     => C,
			Stage => u4_Stage ,
			DoneP => u4_DoneP
		);
	


	genclk : process
		begin
			Clk <= '1';
			wait for tCK / 2;
			Clk <= '0';
			wait for tCK / 2;
			
		end process ;
		

	genreset : process
		begin
			Reset <= '1' ;
			wait for tCK * 3.5 ;
			Reset <= '0' ;
			
			wait ;
		end process ;
		

	gendata : process
		begin
			A <= '0' ;
			B <= '0' ;
			C <= '0' ;
			
			wait for tCK * 10 ;
			wait until rising_edge( Clk ) ;
			wait for tCK / 4 ;
			A <= '1' ;
			wait until rising_edge( Clk ) ;
			wait for tCK / 4 ;
			A <= '0' ;
			
			wait for tCK * 500 ;
			wait for tCK * 10 ;
			wait until rising_edge( Clk ) ;
			wait for tCK / 4 ;
			B <= '1' ;
			wait until rising_edge( Clk ) ;
			wait for tCK / 4 ;
			B <= '0' ;
			
			wait for tCK * 500 ;
			wait for tCK * 10 ;
			wait until rising_edge( Clk ) ;
			wait for tCK / 4 ;
			C <= '1' ;
			wait until rising_edge( Clk ) ;
			wait for tCK / 4 ;
			C <= '0' ;
			
			wait ;
		end process ;
	
	monitor : process
		begin
			wait for tCK * 10 ;
			
			loop
				wait until rising_edge( Clk ) ;
				assert (u1_DoneP = u2_DoneP) and (u2_DoneP = u3_DoneP) and (u3_DoneP = u4_DoneP) ;
				assert (u1_Stage = u2_Stage) and (u2_Stage = u3_Stage) and (u3_Stage = u4_Stage) ;
			end loop ;
			wait ;
		end process ;
end architecture sim;
