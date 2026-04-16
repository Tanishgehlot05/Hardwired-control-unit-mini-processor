
`timescale 1ns/1ps

module control_unit_tb;


    // DUT I/O Signals

    reg clk, rst;
    reg [3:0] Opcode;  //Opcode ~ opcode 
    wire reg_write, mem_read, mem_write, pc_inc, ir_load, mem_to_reg;
    
    wire [1:0] alu_op;

    
    // Initializing DUT
   
    control_unit DUT (
        .clk(clk),
        
        .rst(rst),
        
        .Opcode(Opcode),
        
        .reg_write(reg_write),
        
        .mem_read(mem_read),
        
        .mem_write(mem_write),
        
        .pc_inc(pc_inc),
        
        .ir_load(ir_load),
        
        .mem_to_reg(mem_to_reg),
        
        .alu_op(alu_op)
    );

    // ------------------------------
    // Clock period is set to 10 ns consdering the Flip Flop and Gate delays ~5-6 ns
    // ------------------------------
    always #5 clk = ~clk; // This is on for 5 ns the off for 5 ns
    
    // Clock generation
    // 10 ns period = 100 MHz
    // ("#5" = half period toggling)

    // Start Simulatin Here
    initial begin
        $dumpfile("control_unit.vcd"); // for GTKWave
        $dumpvars(0, control_unit_tb);

        clk = 0;
        rst = 1;
        Opcode = 4'b0000;

        #10 rst = 0; // 10ns after reset clk

        $display("\n====================================================");
        $display("                CONTROL UNIT FSM                 ");
        $display("====================================================\n");

        
        // 1. BASIC INSTRUCTION TESTS
        
        $display("--------------- Test 1: BASIC INSTRUCTION SET ---------------");
        Opcode = 4'b0000;  #40;   // NOP
        Opcode = 4'b0001;  #40;   // ADD
        
        Opcode = 4'b0010;  #40;   // SUB
        Opcode = 4'b0011;  #60;   // LOAD
        
        Opcode = 4'b0100;  #60;   // STORE
        $display("-------------------------------------------------------------\n");

       
        // 2. SEQUENTIAL INSTRUCTION MIX
        
        $display("--------------- Test 2: ADD -> STORE -> SUB -> LOAD -> NOP ---------------");
        Opcode = 4'b0001;  #40;  // ADD
        
        Opcode = 4'b0100;  #40;   // STORE
        
        Opcode = 4'b0010;  #40;   // SUB
        
        Opcode = 4'b0011;  #40;  // LOAD
        
        Opcode = 4'b0000;  #40;   // NOP
        $display("--------------------------------------------------------------------------\n");

        // =======================================================
        // 3. UNDEFINED OPCODES
        // =======================================================
        $display("--------------- Test 3: UNDEFINED OPCODES (0101, 1111) ---------------");
        Opcode = 4'b0101;  #40;  // Undefined → acts as NOP
        
        Opcode = 4'b1111;  #40;  // Undefined → acts as NOP
        $display("---------------------------------------------------------------------\n");

        // =======================================================
        // 4. REPEATED MEMORY INSTRUCTIONS
        // =======================================================
        $display("--------------- Test 4: REPEATED LOAD & STORE ---------------");
        Opcode = 4'b0011;  #40;  // LOAD
        
       Opcode = 4'b0011;  #40;   // LOAD again
       
          Opcode = 4'b0100;  #40;  // STORE
          
            Opcode = 4'b0100;  #40;   // STORE again
        $display("-------------------------------------------------------------\n");

       
        // 5. ALTERNATING ALU / MEMORY INSTRUCTIONS
        
        $display("--------------- Test 5: ADD -> LOAD -> SUB -> STORE ---------------");
        Opcode = 4'b0001;  #40;   // ADD
       Opcode = 4'b0011;  #40;   // LOAD
           Opcode = 4'b0010;  #40;   // SUB
        Opcode = 4'b0100;  #40;   // STORE
        $display("---------------------------------------------------------------\n");

       
        // 6. NOP FLOOD STABILITY TEST
       
        $display("--------------- Test 6: NOP FLOOD (STABILITY CHECK) ---------------");
        Opcode = 4'b0000;  #200;  // FSM should loop FETCH <-> DECODE
        $display("------------------------------------------------------------------\n");

        // End of Simulation
       $display("\n====================================================");
        $display("         ALL EXTENDED TESTS COMPLETED SUCCESSFULLY");
          $display("====================================================\n");

        $finish;
    end

    //yahan pe hum har clock pe state print kar rahe hain
    always @(posedge clk) begin
        $display("[%8t ns]  State=%0d | Opcode=%b | pc_inc=%b | mem_read=%b | mem_write=%b | alu_op=%b | reg_write=%b | mem_to_reg=%b | ir_load=%b",
                 $realtime/1000.0, DUT.state, Opcode, pc_inc, mem_read, mem_write, alu_op, reg_write, mem_to_reg, ir_load);
    end

endmodule

