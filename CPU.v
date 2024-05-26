`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.05.2024 15:06:30
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define ADRES_BIT 32
`define VERI_BIT 32
`define YAZMAC_SAYISI 32
`define BELLEK_ADRES 32'h8000_0000

module CPU(
    input  clk,
    
    input  rst,
    output [`ADRES_BIT-1:0] bellek_adres,
    input [`VERI_BIT-1:0] bellek_oku_veri,
    output [`VERI_BIT-1:0] bellek_yaz_veri,
    output bellek_yaz
    
    );
    
    localparam GETIR        = 2'd0;
    localparam COZYAZMACOKU = 2'd1;
    localparam YURUTGERIYAZ = 2'd2;
    
    reg [1:0]  simdiki_asama_r;
    reg [`VERI_BIT-1:0] yazmac_obegi [0:`YAZMAC_SAYISI-1];
    reg [`ADRES_BIT-1:0] ps_r;
    
    reg [`VERI_BIT-1:0] buyruk;
    reg [`VERI_BIT-1:0] genel_amacli_yazmac_1;
    reg [`VERI_BIT-1:0] genel_amacli_yazmac_2;
    reg [`VERI_BIT-1:0] bellek_yazilacak_veri;
    reg bellek_yaz_sinmi;
                                    
    reg opcode;                     
    reg rd;                         
    reg funct3;                     
    reg rs1;                        
    reg rs2;                        
    reg funct7;                    
    reg imm1;                
    reg [5:0] imm2;                
    reg [3:0] imm3;                 
    reg imm4;                
    reg [7:0] imm5;                 
    reg [3:0] imm6;                 
    reg imm7;                
                                        
    initial begin 
        simdiki_asama_r = GETIR;
        ps_r = `BELLEK_ADRES;
        bellek_yaz_sinmi = 1'b0;
    end
    
    always@(posedge clk) begin 
        if (rst) begin 
            ps_r <= `BELLEK_ADRES;
            simdiki_asama_r <= GETIR;
        end
        else begin
        
            case(simdiki_asama_r)
            
                GETIR: begin
                    buyruk = bellek_oku_veri;
                    simdiki_asama_r = COZYAZMACOKU;
                end
                
                COZYAZMACOKU: begin
                
                    opcode = buyruk [6:0];
                    rd     = buyruk [11:7];
                    funct3 = buyruk [14:12];
                    rs1    = buyruk [19:15];
                    rs2    = buyruk [24:20];
                    funct7 = buyruk [31:25];
                    imm1   = buyruk [31];
                    imm2   = buyruk [30:25];
                    imm3   = buyruk [24:21];
                    imm4   = buyruk [20];
                    imm5   = buyruk [19:12];
                    imm6   = buyruk [11:8];
                    imm7   = buyruk [7];
                    
                    case (opcode)
                    
                        //LUI
                        7'b0110111: genel_amacli_yazmac_1 = {imm1, imm2, imm3, imm4, imm5, 12'b0};
                        //AUIPC
                        7'b0010111: genel_amacli_yazmac_1 = {imm1, imm2, imm3, imm4, imm5, 12'b0};
                        //JAL
                        7'b1101111: genel_amacli_yazmac_1 = (imm1 == 1) ? {12'b1, imm5, imm4, imm2, imm3, 1'b0} : {12'b0, imm5, imm4, imm2, imm3, 1'b0};
                        //JALR
                        7'b1100111: genel_amacli_yazmac_1 = ((imm1 == 1) ? {21'b1, imm2, imm3, imm4} : {21'b0, imm2, imm3, imm4}) + yazmac_obegi[rs1];
                        //B-Type
                        7'b1100011: genel_amacli_yazmac_1 = (imm1 == 1) ? {20'b1, imm7, imm2, imm6, 1'b0} : {20'b0, imm7, imm2, imm6, 1'b0};
                        //LW
                        7'b0000011: genel_amacli_yazmac_1 = ((imm1 == 1) ? {21'b1, imm2, imm3, imm4} : {21'b0, imm2, imm3, imm4}) + yazmac_obegi[rs1];
                        //SW
                        7'b0100011: begin 
                            genel_amacli_yazmac_2 = ps_r;
                            ps_r = ((imm1 == 1) ? {21'b1, imm2, imm6, imm7} : {21'b0, imm2, imm6, imm7}) + yazmac_obegi[rs1];                
                            bellek_yaz_sinmi = 1'b1;
                            bellek_yazilacak_veri = yazmac_obegi[rs2];
                            
                            //bellek_yazilacak_veri = yazmac_obegi[buyruk [24:20]];
                            
                        end      
                        //ADDI
                        7'b0010011: genel_amacli_yazmac_1 = (imm1 == 1) ? {21'b1, imm2, imm3, imm4} : {21'b0, imm2, imm3, imm4};
                        //R-Type
                        7'b0110011: begin 
                            genel_amacli_yazmac_1 = yazmac_obegi[rs1];
                            genel_amacli_yazmac_2 = yazmac_obegi[rs2];
                        end
                        default: begin end
                    endcase
                    simdiki_asama_r = YURUTGERIYAZ;
                end
                YURUTGERIYAZ: begin
                    case (opcode)
                    
                        //LUI
                        7'b0110111: begin
                            yazmac_obegi[rd] = genel_amacli_yazmac_1;
                            ps_r = ps_r + 4;
                        end
                        //AUIPC
                        7'b0010111: begin 
                            yazmac_obegi[rd] = genel_amacli_yazmac_1 + ps_r;
                            ps_r = ps_r + 4;
                        end
                        //JAL
                        7'b1101111: begin 
                            yazmac_obegi[rd] = ps_r + 4;
                            ps_r = ps_r + genel_amacli_yazmac_1;
                        end
                        //JALR
                        7'b1100111: begin 
                            yazmac_obegi[rd] = ps_r + 4;
                            ps_r = {genel_amacli_yazmac_1[31:1], 1'b0};
                        end
                        //B-Type
                        7'b1100011: begin 
                            case (funct3)
                            
                                //BEQ
                                3'b000: ps_r = (yazmac_obegi[rs1] == yazmac_obegi[rs2]) ? (ps_r + genel_amacli_yazmac_1) : (ps_r + 4);
                                //BNE
                                3'b001: ps_r = (yazmac_obegi[rs1] != yazmac_obegi[rs2]) ? (ps_r + genel_amacli_yazmac_1) : (ps_r + 4);
                                //BLT
                                3'b100: ps_r = (yazmac_obegi[rs1]  < yazmac_obegi[rs2]) ? (ps_r + genel_amacli_yazmac_1) : (ps_r + 4);
                                default: begin end
                            endcase
                        end
                        //LW
                        7'b0000011: begin  
                            genel_amacli_yazmac_2 = ps_r;
                            ps_r = genel_amacli_yazmac_1;
                            yazmac_obegi[rd] = bellek_oku_veri;
                            ps_r = genel_amacli_yazmac_2 + 4;
                        end
                        //SW
                        7'b0100011: begin 
                            bellek_yaz_sinmi = 1'b0;
                            ps_r = genel_amacli_yazmac_2 + 4;
                        end
                        //ADDI
                        7'b0010011: begin 
                            yazmac_obegi[rd] = genel_amacli_yazmac_1 + yazmac_obegi[rs1];
                            ps_r = ps_r + 4;
                        end
                        //R-Type
                        7'b0110011: begin
                            case (funct7)
                                7'b0000000: begin
                                    case (funct3)
                                        3'b000: yazmac_obegi[rd] = yazmac_obegi[rs1] + yazmac_obegi[rs2];
                                        3'b100: yazmac_obegi[rd] = yazmac_obegi[rs1] ^ yazmac_obegi[rs2];
                                        3'b110: yazmac_obegi[rd] = yazmac_obegi[rs1] | yazmac_obegi[rs2];
                                        3'b111: yazmac_obegi[rd] = yazmac_obegi[rs1] & yazmac_obegi[rs2];
                                        default: begin end
                                    endcase
                                end
                                7'b0100000: yazmac_obegi[rd] = yazmac_obegi[rs1] - yazmac_obegi[rs2];
                                default: begin end
                           endcase
                            ps_r = ps_r + 4;
                        end
                        default: begin end
                    endcase
                    simdiki_asama_r = GETIR;                    
                end
                default: begin end
            endcase
        end
    end
    assign bellek_adres = ps_r;
    assign bellek_yaz_veri = bellek_yazilacak_veri;
    assign bellek_yaz = bellek_yaz_sinmi;
endmodule













