
// FSM-based Hardwired Control Unit Control unit VF

// Author : G10 Cs203 
module control_unit(
    input clk,
    input rst,
    input [3:0] Opcode,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg pc_inc,
    output reg ir_load,
    output reg mem_to_reg,
    output reg [1:0] alu_op
);

    // FSM State 
     // Each state corresponds to a instruction execution.
    localparam FETCH     = 3'd0,
               DECODE    = 3'd1,
               EXEC_ALU  = 3'd2,
               WB_ALU    = 3'd3,
               EXEC_MEM  = 3'd4,
               WB_MEM    = 3'd5;

    // ALU Operation 
    localparam ALU_ADD  = 2'b00, // These are the numbring of operations 
               ALU_SUB  = 2'b01,
               ALU_PASS = 2'b10;  // For address calculation / default

    
    reg [2:0] state, next_state;
    wire is_ADD, is_SUB, is_LOAD, is_STORE, is_NOP;  // Here are the wires

   
    opcode_decoder decoder_inst(  // Yaha Decoder ko start kiya hai 
        .Opcode(Opcode),  
        .is_ADD(is_ADD), .is_SUB(is_SUB), .is_LOAD(is_LOAD),
        .is_STORE(is_STORE), .is_NOP(is_NOP)
    );

   
    // State Register
  
    always @(posedge clk or posedge rst) begin  // Ye Positive edge Trigerred Hai
        if (rst)
            state <= FETCH;  // State 0
        else
            state <= next_state; //State ++
    end

  
    // Next-State Logic
   // what happen in next state --
    always @(*) begin
        next_state = state;
        case (state)
            FETCH:  next_state = DECODE;
            
            DECODE: begin
                if (is_ADD || is_SUB)
                
                next_state = EXEC_ALU;
                   
                else if (is_LOAD || is_STORE)
                
                   next_state = EXEC_MEM;
                else
              next_state = FETCH; // NOP
            end
               EXEC_ALU: next_state = WB_ALU;
               
          WB_ALU:   next_state = FETCH;
            
         EXEC_MEM: next_state = is_LOAD ? WB_MEM : FETCH;
         
             WB_MEM:   next_state = FETCH;
              
            default:  next_state = FETCH;
        endcase
    end

    //=====================
    // Output Logic (Combinational)
    //=====================
    always @(*) begin
        // Default outputs
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        pc_inc     = 0;
        ir_load    = 0;
        mem_to_reg = 0;
        alu_op     = ALU_PASS;

        case (state)
            FETCH: begin
                pc_inc   = 1;
                mem_read = 1;
                ir_load  = 1;
            end
            DECODE: ; // no control signals
            EXEC_ALU: alu_op = is_ADD ? ALU_ADD : (is_SUB ? ALU_SUB : ALU_PASS);
            
            WB_ALU: begin
                reg_write  = 1;
                
                mem_to_reg = 0; // write th ALU result
            end
            EXEC_MEM: begin
                alu_op = ALU_PASS; // address calculations
                if (is_LOAD)
                
                    mem_read = 1;
                else if (is_STORE)
                    mem_write = 1;
                    
            end
            WB_MEM: begin
                reg_write  = 1;
                mem_to_reg = 1; // write the data to the memory back
                
            end
        endcase
    end
endmodule
