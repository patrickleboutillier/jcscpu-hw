RAM[0]  = 8'b00100000 ; // DATA  R0, 00000000 (0)
RAM[1]  = 8'b00000000 ;
RAM[2]  = 8'b01111100 ; // OUTA  R0
RAM[3]  = 8'b00100000 ; // DATA  R0, 00010100 (20)
RAM[4]  = 8'b00010100 ;
RAM[5]  = 8'b01111000 ; // OUTD  R0
RAM[6]  = 8'b00100001 ; // DATA  R1, 00010110 (22)
RAM[7]  = 8'b00010110 ;
RAM[8]  = 8'b01111001 ; // OUTD  R1
RAM[9]  = 8'b10000001 ; // ADD   R0, R1
RAM[10] = 8'b01111001 ; // OUTD  R1
RAM[11] = 8'b01100001 ; // HALT