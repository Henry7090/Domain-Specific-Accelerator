`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2024 10:18:22 PM
// Design Name: 
// Module Name: data_feeder_con3d_24
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


module data_feeder_con3d_24 #(
    parameter XLEN = 32
) (
    // System signals
    input                   clk_i,
    input                   rst_i,

    // Device bus signals
    input                   en_i,
    input                   we_i,
    input [XLEN-1 : 0]      addr_i,
    input [XLEN-1 : 0]      data_i,
    output reg              ready_o,
    output reg [XLEN-1 : 0]     data_o
);

reg [XLEN-1 : 0] data_a;
reg [XLEN-1 : 0] data_b;
reg [XLEN-1 : 0] data_c;
wire [XLEN-1 : 0] answer;
reg data_a_valid;
reg data_b_valid;
reg data_c_valid;
wire answer_valid;
reg [XLEN-1 : 0] weight [0:24];
reg [XLEN-1 : 0] weightcount;
always @(posedge clk_i)begin
    if(rst_i)begin
        data_a <= 0;
        data_b <= 0;
        data_a_valid <= 0;
        data_b_valid <= 0;
        weightcount <=  0;
    end
    else if(valid && addr_i == 32'hC4300008 && !we_i)begin
        data_o <= answer_reg;
        ready_o <= 1;
        data_a_valid <= 0;
        data_b_valid <= 0;
        data_c_valid <= 0;
    end
    else if(en_i)begin
        if(we_i) begin
            if(addr_i == 32'hC4300000)begin
                ready_o <= 1;
                weight[weightcount] <= data_i;
                if(weightcount == 24)begin
                    weightcount <= 0;
                end
                else begin
                    weightcount <= weightcount + 1;
                end
            end
            else if(addr_i == 32'hC4300004)begin
                data_a <= weight[weightcount];
                data_a_valid <= 1;
                data_b <= data_i;
                data_b_valid <= 1;
                ready_o <= 1;
                if(weightcount == 24)begin
                    weightcount <= 0;
                end
                else begin
                    weightcount <= weightcount + 1;
                end
            end
            else if(addr_i == 32'hC430000c)begin
                data_c <= data_i;
                data_c_valid <= 1;
                ready_o <= 1;
            end
        end 
    end
    else begin
        ready_o <= 0;
    end
end



floating_point_0 floating_point_0(
    .aclk(clk_i),
    .s_axis_a_tvalid(data_a_valid),
    .s_axis_a_tdata(data_a),

    .s_axis_b_tvalid(data_b_valid),
    .s_axis_b_tdata(data_b),

    .s_axis_c_tvalid(data_c_valid),
    .s_axis_c_tdata(data_c),

    .m_axis_result_tvalid(answer_valid),
    .m_axis_result_tdata(answer)
);

reg valid;
reg [XLEN -1:0] answer_reg;
always @(posedge clk_i)begin
    if(rst_i)begin
        valid <= 0;
    end
    else if(answer_valid && data_c_valid)begin
        valid <= 1;
        answer_reg <= answer;
    end
    else begin
        valid <= 0;
    end
end

endmodule
