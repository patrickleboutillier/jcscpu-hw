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
            RAM[9]  = 8'b01100000 ; // CLF because FLAGS is not properly initialized
            RAM[10] = 8'b10000001 ; // ADD   R0, R1
            RAM[11] = 8'b01111001 ; // OUTD  R1
            RAM[12] = 8'b01100001 ; // HALT
        end
    endtask
endmodule