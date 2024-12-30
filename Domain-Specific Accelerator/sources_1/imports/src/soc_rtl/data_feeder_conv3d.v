`timescale 1ns / 1ps


module data_feeder_con3d_8 #(
    parameter XLEN = 32
) (
    // System signals
    input                   clk_i,
    input                   rst_i,

    // Device bus signals
    (* mark_debug = "true" *) input                   en_i,
    (* mark_debug = "true" *) input                   we_i,
    (* mark_debug = "true" *) input [XLEN-1 : 0]      addr_i,
    (* mark_debug = "true" *) input [XLEN-1 : 0]      data_i,
    output reg              ready_o,
    output reg [XLEN-1 : 0]     data_o
);



(* mark_debug = "true" *) reg [XLEN-1 : 0] try1;
(* mark_debug = "true" *) reg [XLEN-1 : 0] try2;
reg [XLEN-1 : 0] img [0:143];
reg [XLEN-1 : 0] weight [0:24];
reg [10:0] weightcount;  
(* mark_debug = "true" *) reg [10:0] img_count;
reg [XLEN - 1 :0] index;
always @(posedge clk_i) begin
    if (rst_i) begin
        weightcount <= 0;
        index <= 0;
        img_count  <= 0;
    end 
    else if (en_i) begin
        if (we_i) begin
            if (addr_i == 32'hC4400000) begin
                weight[weightcount] <= data_i;
                if (weightcount == 24) begin
                    weightcount <= 0;
                end 
                else begin
                    weightcount <= weightcount + 1;
                end
            end 
            else if (addr_i == 32'hC4400004) begin
                img[img_count] <= data_i; 
                if (img_count == 143) begin
                    try1 <= data_i;
                    img_count <= 0;
                end else begin
                    img_count <= img_count + 1;
                end
            end 
            else if (addr_i == 32'hC4400008)begin
                index <= data_i;
            end
        end
    end
end




// ready_o signal and answer
reg  [XLEN-1:0] answer;
always @(posedge clk_i) begin
    if (rst_i) begin
        ready_o <= 0;
        data_o <= 0;
    end 
    else if (en_i) begin
        if (we_i) begin
            if (addr_i == 32'hC4400000 || addr_i == 32'hC4400004 || addr_i == 32'hC4400008) begin
                ready_o <= 1;
            end 
        end
    end
    else if(addr_i == 32'hC440000c && S == S_FINISH)begin
        ready_o <= 1;
        data_o <= answer;
    end
    else begin
        ready_o <= 0;
    end
end


reg  [XLEN-1:0] mul_img [0:24];
reg  [XLEN-1:0] mul_weight [0:24]; // Array of 25 registers
wire [XLEN-1:0] mul_answer[0:24];
wire [24:0] mul_valid;
wire mulfinish;
assign mulfinish = &mul_valid; 



reg [2:0] S, S_next;
localparam  S_IDLE = 0, S_INIT = 1, S_MUL = 2, S_ADD_INITIALIZE = 3,
            S_ADD = 4, S_FINISH = 5;

always @(posedge clk_i)
begin
    if(rst_i) S <= S_IDLE;
    else  S <= S_next;
end




always @(*)
begin
    S_next = S;
    case(S)
        S_IDLE:begin
            if(addr_i == 32'hC440000c && en_i)begin
                S_next = S_INIT;
            end
        end
        S_INIT:begin
            if(valid)begin
                S_next = S_MUL;
            end
        end
        S_MUL:begin
            if(mulfinish)begin
                S_next = S_ADD_INITIALIZE;
            end
        end
        S_ADD_INITIALIZE:begin
            S_next = S_ADD;
        end
        S_ADD:begin
            if(result_valid)begin
                if(counter == 25)begin
                    S_next = S_FINISH;
                end
                else begin
                    S_next = S_ADD_INITIALIZE;
                end
            end
        end
        S_FINISH:begin
            S_next = S_IDLE;
        end
    endcase
end

integer i, j;
reg valid;
//reg [10:0] index;
always @(posedge clk_i) begin
    if (rst_i) begin
        for (j = 0; j < 25; j = j + 1) begin
            mul_img[j] <= 0; // Reset all elements
        end
    end else if (S == S_INIT) begin
        mul_img[0]  <= img[index + 0     ];
        mul_img[1]  <= img[index + 1     ];
        mul_img[2]  <= img[index + 2     ];
        mul_img[3]  <= img[index + 3     ];
        mul_img[4]  <= img[index + 4     ];

        mul_img[5]  <= img[index + 0 + 12];
        mul_img[6]  <= img[index + 1 + 12];
        mul_img[7]  <= img[index + 2 + 12];
        mul_img[8]  <= img[index + 3 + 12];
        mul_img[9]  <= img[index + 4 + 12];

        mul_img[10] <= img[index + 0 + 24];
        mul_img[11] <= img[index + 1 + 24];
        mul_img[12] <= img[index + 2 + 24];
        mul_img[13] <= img[index + 3 + 24];
        mul_img[14] <= img[index + 4 + 24];
        
        mul_img[15] <= img[index + 0 + 36];
        mul_img[16] <= img[index + 1 + 36];
        mul_img[17] <= img[index + 2 + 36];
        mul_img[18] <= img[index + 3 + 36];
        mul_img[19] <= img[index + 4 + 36];

        mul_img[20] <= img[index + 0 + 48];
        mul_img[21] <= img[index + 1 + 48];
        mul_img[22] <= img[index + 2 + 48];
        mul_img[23] <= img[index + 3 + 48];
        mul_img[24] <= img[index + 4 + 48];
        for (j = 0; j < 25; j = j + 1) begin
            mul_weight[j] <= weight[j]; 
        end
    end
end


always @(posedge clk_i) begin
    if (rst_i) begin
        valid <= 0;
    end else if (S == S_INIT) begin
        valid <= 1;
    end
    else if(S == S_MUL && mulfinish)begin
        valid <= 0;
    end
end

reg  [XLEN-1:0] adder1;
reg  [XLEN-1:0] adder2;
reg add_valid;
always@(posedge clk_i)begin
    if(rst_i)begin
        adder1 <= 0;
        add_valid <= 0;
        adder2 <= 0;
    end
    else if(S == S_ADD_INITIALIZE)begin
        if(counter == 0)begin
            adder1 <= 0;
            adder2 <= mul_answer[0];
            add_valid <= 1;
        end
        else begin
            adder1 <= answer;
            adder2 <= mul_answer[counter];
            add_valid <= 1;
        end     
    end
    else begin
        add_valid <= 0;
    end
end

reg [10:0] counter;
always@(posedge clk_i)begin
    if(rst_i)begin
        counter <= 0;
    end
    else if(S == S_ADD_INITIALIZE)begin
        counter <= counter + 1;
    end
    else if(S==S_FINISH)begin
        counter <= 0;
    end
end

wire add_result_valid;
wire [XLEN-1:0] add_result;
reg result_valid;
always@(posedge clk_i)begin
    if(rst_i)begin
        answer<=0;
        result_valid <= 0;
    end
    else if(S == S_ADD)begin
        if(add_result_valid)begin
            answer <= add_result;
            result_valid <= 1;
        end
    end
    else if(S == S_FINISH)begin
        answer <= 0;
        result_valid <= 0;
    end
    else begin
        result_valid <= 0;
    end
end

FP_ADD fp_add (
    .aclk(clk_i),
    .s_axis_a_tvalid(add_valid),
    .s_axis_a_tdata(adder1),      
    .s_axis_b_tvalid(add_valid),
    .s_axis_b_tdata(adder2), 
    .m_axis_result_tvalid(add_result_valid),  
    .m_axis_result_tdata(add_result)         
);


genvar k;
generate
    for (k = 0; k < 25; k = k + 1) begin : FP_MUX_INST
        FP_MUX fp_MUX_inst (
            .aclk(clk_i),
            .s_axis_a_tvalid(valid),
            .s_axis_a_tdata(mul_img[k]),     
            .s_axis_b_tvalid(valid),
            .s_axis_b_tdata(mul_weight[k]), 

            .m_axis_result_tvalid(mul_valid[k]), 
            .m_axis_result_tdata(mul_answer[k])         
        );
    end
endgenerate

endmodule