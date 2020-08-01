module ram(input [7:0] bas, input wsa, input [7:0] bis, input ws, input we, output wor [7:0] bos) ;
    wire [7:0] busd ;
    jregister MAR(bas, wsa, 1'b1, busd) ;

    reg [7:0] RAM[0:255] ;
    assign bos = (we) ? RAM[busd] : 0 ;
    always @(ws or bis or busd) begin
        if (ws)
            RAM[busd] = bis ;
    end
    // Initialize RAM
    initial begin
        prog_42() ;
    end
    
    // Program 20 + 22 = 42 ;
    task prog_42 ; 
        begin
            RAM[0]  = 8'b00100000 ; // DATA  R0, 00000000 (0)
            RAM[1]  = 8'b00000000 ;
            RAM[2]  = 8'b01111100 ; // OUTA  R0
            RAM[3]  = 8'b00100000 ; // DATA  R0, 00010100 (20)
            RAM[4]  = 8'b00010100 ;
            RAM[5]  = 8'b01111000 ; // OUTD  R0
            RAM[6]  = 8'b00100001 ; // DATA  R1, 00010110 (22)
            RAM[7]  = 8'b00010110 ;
            RAM[8]  = 8'b01111001 ; // OUTD  R1
            RAM[9] = 8'b10000001 ; // ADD   R0, R1
            RAM[10] = 8'b01111001 ; // OUTD  R1
            RAM[11] = 8'b01100001 ; // HALT
        end
    endtask
    
    // Program 5x5
    task prog_5x5 ; 
        begin    
            RAM[0] = 8'b00100000 ; // line   0, pos   0 - DATA  R0, 00000101 (5)
            RAM[1] = 8'b00000101 ; // line   1, pos   1 -       00000101 (5)
            RAM[2] = 8'b00100001 ; // line   2, pos   2 - DATA  R1, 00000101 (5)
            RAM[3] = 8'b00000101 ; // line   3, pos   3 -       00000101 (5)
            RAM[4] = 8'b00100011 ; // line   4, pos   4 - DATA  R3, 00000001 (1)
            RAM[5] = 8'b00000001 ; // line   5, pos   5 -       00000001 (1)
            RAM[6] = 8'b11101010 ; // line   6, pos   6 - XOR   R2, R2
            RAM[7] = 8'b01100000 ; // line   7, pos   7 - CLF   
            RAM[8] = 8'b10010000 ; // line   8, pos   8 - SHR   R0, R0
            RAM[9] = 8'b01011000 ; // line   9, pos   9 - JC    00001101 (13)
            RAM[10] = 8'b00001101 ; // line  10, pos  10 -       00001101 (13)
            RAM[11] = 8'b01000000 ; // line  11, pos  11 - JMP   00001111 (15)
            RAM[12] = 8'b00001111 ; // line  12, pos  12 -       00001111 (15)
            RAM[13] = 8'b01100000 ; // line  13, pos  13 - CLF   
            RAM[14] = 8'b10000110 ; // line  14, pos  14 - ADD   R1, R2
            RAM[15] = 8'b01100000 ; // line  15, pos  15 - CLF   
            RAM[16] = 8'b10100101 ; // line  16, pos  16 - SHL   R1, R1
            RAM[17] = 8'b10101111 ; // line  17, pos  17 - SHL   R3, R3
            RAM[18] = 8'b01011000 ; // line  18, pos  18 - JC    00010110 (22)
            RAM[19] = 8'b00010110 ; // line  19, pos  19 -       00010110 (22)
            RAM[20] = 8'b01000000 ; // line  20, pos  20 - JMP   00000111 (7)
            RAM[21] = 8'b00000111 ; // line  21, pos  21 -       00000111 (7)
            RAM[22] = 8'b00100000 ; // DATA  R0, 00000000 (0)
            RAM[23] = 8'b00000000 ; // ...   0
            RAM[24] = 8'b01111100 ; // OUTA  R0
            RAM[25] = 8'b01111010 ; // OUTD  R2
            RAM[26] = 8'b01100001 ; // HALT
        end
    endtask
endmodule