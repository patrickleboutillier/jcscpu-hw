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
            RAM[9]  = 8'b10000001 ; // ADD   R0, R1
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
            RAM[7] = 8'b01111110 ; // line   7, pos   7 - OUTA  R2
            RAM[8] = 8'b01100000 ; // line   8, pos   8 - CLF   
            RAM[9] = 8'b01111010 ; // line   9, pos   9 - OUTD  R2
            RAM[10] = 8'b10010000 ; // line  10, pos  10 - SHR   R0, R0
            RAM[11] = 8'b01011000 ; // line  11, pos  11 - JC    00001111 (15)
            RAM[12] = 8'b00001111 ; // line  12, pos  12 -       00001111 (15)
            RAM[13] = 8'b01000000 ; // line  13, pos  13 - JMP   00010001 (17)
            RAM[14] = 8'b00010001 ; // line  14, pos  14 -       00010001 (17)
            RAM[15] = 8'b01100000 ; // line  15, pos  15 - CLF   
            RAM[16] = 8'b10000110 ; // line  16, pos  16 - ADD   R1, R2
            RAM[17] = 8'b01100000 ; // line  17, pos  17 - CLF   
            RAM[18] = 8'b10100101 ; // line  18, pos  18 - SHL   R1, R1
            RAM[19] = 8'b10101111 ; // line  19, pos  19 - SHL   R3, R3
            RAM[20] = 8'b01011000 ; // line  20, pos  20 - JC    00011000 (24)
            RAM[21] = 8'b00011000 ; // line  21, pos  21 -       00011000 (24)
            RAM[22] = 8'b01000000 ; // line  22, pos  22 - JMP   00001000 (8)
            RAM[23] = 8'b00001000 ; // line  23, pos  23 -       00001000 (8)
            RAM[24] = 8'b01100001 ; // line  24, pos  24 - HALT  
        end
    endtask
    
    task prog_fib ;
        begin
            RAM[0] = 8'b00100000 ; // line   0, pos   0 - DATA  R0, 00000000 (0)
            RAM[1] = 8'b00000000 ; // line   1, pos   1 -       00000000 (0)
            RAM[2] = 8'b00100001 ; // line   2, pos   2 - DATA  R1, 11111111 (255)
            RAM[3] = 8'b11111111 ; // line   3, pos   3 -       11111111 (255)
            RAM[4] = 8'b00010100 ; // line   4, pos   4 - ST    R1, R0
            RAM[5] = 8'b00100000 ; // line   5, pos   5 - DATA  R0, 00000001 (1)
            RAM[6] = 8'b00000001 ; // line   6, pos   6 -       00000001 (1)
            RAM[7] = 8'b00100001 ; // line   7, pos   7 - DATA  R1, 11111110 (254)
            RAM[8] = 8'b11111110 ; // line   8, pos   8 -       11111110 (254)
            RAM[9] = 8'b00010100 ; // line   9, pos   9 - ST    R1, R0
            RAM[10] = 8'b00100000 ; // line  10, pos  10 - DATA  R0, 00001101 (12)
            RAM[11] = 8'b00001100 ; // line  11, pos  11 -       00001101 (12)
            RAM[12] = 8'b00100001 ; // line  12, pos  12 - DATA  R1, 11111101 (253)
            RAM[13] = 8'b11111101 ; // line  13, pos  13 -       11111101 (253)
            RAM[14] = 8'b00010100 ; // line  14, pos  14 - ST    R1, R0
            RAM[15] = 8'b00100000 ; // line  15, pos  15 - DATA  R0, 11111111 (255)
            RAM[16] = 8'b11111111 ; // line  16, pos  16 -       11111111 (255)
            RAM[17] = 8'b00000000 ; // line  17, pos  17 - LD    R0, R0
            RAM[18] = 8'b00100011 ; // line  18, pos  18 - DATA  R3, 00000000 (0)
            RAM[19] = 8'b00000000 ; // line  19, pos  19 -       00000000 (0)
            RAM[20] = 8'b01111111 ; // line  20, pos  20 - OUTA  R3
            RAM[21] = 8'b01111000 ; // line  21, pos  21 - OUTD  R0
            RAM[22] = 8'b00100000 ; // line  22, pos  22 - DATA  R0, 11111110 (254)
            RAM[23] = 8'b11111110 ; // line  23, pos  23 -       11111110 (254)
            RAM[24] = 8'b00000000 ; // line  24, pos  24 - LD    R0, R0
            RAM[25] = 8'b00100011 ; // line  25, pos  25 - DATA  R3, 00000000 (0)
            RAM[26] = 8'b00000000 ; // line  26, pos  26 -       00000000 (0)
            RAM[27] = 8'b01111111 ; // line  27, pos  27 - OUTA  R3
            RAM[28] = 8'b01111000 ; // line  28, pos  28 - OUTD  R0
            RAM[29] = 8'b00100000 ; // line  30, pos  29 - DATA  R0, 11111101 (253)
            RAM[30] = 8'b11111101 ; // line  31, pos  30 -       11111101 (253)
            RAM[31] = 8'b00000000 ; // line  32, pos  31 - LD    R0, R0
            RAM[32] = 8'b11100101 ; // line  33, pos  32 - XOR   R1, R1
            RAM[33] = 8'b01100000 ; // line  34, pos  33 - CLF   
            RAM[34] = 8'b11110001 ; // line  35, pos  34 - CMP   R0, R1
            RAM[35] = 8'b01010010 ; // line  36, pos  35 - JE    @ELSE35 (@@ELSE35)
            RAM[36] = 8'b01011010 ; // line  37, pos  36 -       @ELSE35 (90)
            RAM[37] = 8'b00100000 ; // line  38, pos  37 - DATA  R0, 11111111 (255)
            RAM[38] = 8'b11111111 ; // line  39, pos  38 -       11111111 (255)
            RAM[39] = 8'b00000000 ; // line  40, pos  39 - LD    R0, R0
            RAM[40] = 8'b00100001 ; // line  41, pos  40 - DATA  R1, 11111110 (254)
            RAM[41] = 8'b11111110 ; // line  42, pos  41 -       11111110 (254)
            RAM[42] = 8'b00000101 ; // line  43, pos  42 - LD    R1, R1
            RAM[43] = 8'b01100000 ; // line  44, pos  43 - CLF   
            RAM[44] = 8'b10000001 ; // line  45, pos  44 - ADD   R0, R1
            RAM[45] = 8'b00100000 ; // line  46, pos  45 - DATA  R0, 11111100 (252)
            RAM[46] = 8'b11111100 ; // line  47, pos  46 -       11111100 (252)
            RAM[47] = 8'b00010001 ; // line  48, pos  47 - ST    R0, R1
            RAM[48] = 8'b00100000 ; // line  49, pos  48 - DATA  R0, 11111110 (254)
            RAM[49] = 8'b11111110 ; // line  50, pos  49 -       11111110 (254)
            RAM[50] = 8'b00000000 ; // line  51, pos  50 - LD    R0, R0
            RAM[51] = 8'b00100001 ; // line  52, pos  51 - DATA  R1, 11111111 (255)
            RAM[52] = 8'b11111111 ; // line  53, pos  52 -       11111111 (255)
            RAM[53] = 8'b00010100 ; // line  54, pos  53 - ST    R1, R0
            RAM[54] = 8'b00100000 ; // line  55, pos  54 - DATA  R0, 11111100 (252)
            RAM[55] = 8'b11111100 ; // line  56, pos  55 -       11111100 (252)
            RAM[56] = 8'b00000000 ; // line  57, pos  56 - LD    R0, R0
            RAM[57] = 8'b00100001 ; // line  58, pos  57 - DATA  R1, 11111110 (254)
            RAM[58] = 8'b11111110 ; // line  59, pos  58 -       11111110 (254)
            RAM[59] = 8'b00010100 ; // line  60, pos  59 - ST    R1, R0
            RAM[60] = 8'b00100000 ; // line  61, pos  60 - DATA  R0, 11111110 (254)
            RAM[61] = 8'b11111110 ; // line  62, pos  61 -       11111110 (254)
            RAM[62] = 8'b00000000 ; // line  63, pos  62 - LD    R0, R0
            RAM[63] = 8'b00100011 ; // line  64, pos  63 - DATA  R3, 00000000 (0)
            RAM[64] = 8'b00000000 ; // line  65, pos  64 -       00000000 (0)
            RAM[65] = 8'b01111111 ; // line  66, pos  65 - OUTA  R3
            RAM[66] = 8'b01111000 ; // line  67, pos  66 - OUTD  R0
            RAM[67] = 8'b00100000 ; // line  68, pos  67 - DATA  R0, 00000001 (1)
            RAM[68] = 8'b00000001 ; // line  69, pos  68 -       00000001 (1)
            RAM[69] = 8'b00100001 ; // line  70, pos  69 - DATA  R1, 11111011 (251)
            RAM[70] = 8'b11111011 ; // line  71, pos  70 -       11111011 (251)
            RAM[71] = 8'b00010100 ; // line  72, pos  71 - ST    R1, R0
            RAM[72] = 8'b00100000 ; // line  73, pos  72 - DATA  R0, 11111101 (253)
            RAM[73] = 8'b11111101 ; // line  74, pos  73 -       11111101 (253)
            RAM[74] = 8'b00000000 ; // line  75, pos  74 - LD    R0, R0
            RAM[75] = 8'b00100001 ; // line  76, pos  75 - DATA  R1, 11111011 (251)
            RAM[76] = 8'b11111011 ; // line  77, pos  76 -       11111011 (251)
            RAM[77] = 8'b00000101 ; // line  78, pos  77 - LD    R1, R1
            RAM[78] = 8'b10110101 ; // line  79, pos  78 - NOT   R1, R1
            RAM[79] = 8'b00100010 ; // line  80, pos  79 - DATA  R2, 00000001 (1)
            RAM[80] = 8'b00000001 ; // line  81, pos  80 -       00000001 (1)
            RAM[81] = 8'b01100000 ; // line  82, pos  81 - CLF   
            RAM[82] = 8'b10001001 ; // line  83, pos  82 - ADD   R2, R1
            RAM[83] = 8'b01100000 ; // line  84, pos  83 - CLF   
            RAM[84] = 8'b10000001 ; // line  85, pos  84 - ADD   R0, R1
            RAM[85] = 8'b00100000 ; // line  86, pos  85 - DATA  R0, 11111101 (253)
            RAM[86] = 8'b11111101 ; // line  87, pos  86 -       11111101 (253)
            RAM[87] = 8'b00010001 ; // line  88, pos  87 - ST    R0, R1
            RAM[88] = 8'b01000000 ; // line  90, pos  88 - JMP   @FI35 (@@FI35)
            RAM[89] = 8'b01011100 ; // line  91, pos  89 -       @FI35 (92)
            RAM[90] = 8'b01000000 ; // line  94, pos  90 - JMP   @ELIHW29 (@@ELIHW29)
            RAM[91] = 8'b01011110 ; // line  95, pos  91 -       @ELIHW29 (94)
            RAM[92] = 8'b01000000 ; // line  98, pos  92 - JMP   @WHILE29 (@@WHILE29)
            RAM[93] = 8'b00011101 ; // line  99, pos  93 -       @WHILE29 (29)
            RAM[94] = 8'b01100001 ; // line 101, pos  94 - HALT  (automatically inserted by jscasm)
        end
    endtask
    
    task prog_none ; 
        begin
            RAM[0]  = 8'b01100001 ; // HALT
        end
    endtask
endmodule