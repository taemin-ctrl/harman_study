`timescale 1ns / 1ps
class transaction;
    // APB Interface Signals
    rand logic [ 3:0] PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE;
    rand logic        PENABLE;
    rand logic        PSEL;
    
    logic      [31:0] PRDATA;  // dut out data
    logic             PREADY;  // dut out data
    
    // outport signals
    logic      [ 3:0] fndCom;  // dut out data
    logic      [ 6:0] fndFont;  // dut out data
    logic             dot;
    
    logic [1:0] state;

    constraint c_paddr{
        PADDR == 4'h4;
    }

    constraint c_wdata{
        if (PADDR == 4) PWDATA <10; 
        else if (PADDR == 8) PWDATA[31:4] == 28'b0;
    }

    task display(string name);
        $display("[%s] PADDR: %h, PWDATA: %d, PWRITE: %h, PENABLE: %H, PSEL: %h", 
                name, PADDR, PWDATA, PWRITE, PENABLE, PSEL);
        $display("[%s] result -> PRDATA : %d, PREADY: %h, fndCom: %h, fndFont: %h, dot: %h",
                name, PRDATA,PREADY,fndCom,fndFont,dot);
    endtask 
endclass //transaction

interface APB_Slave_Intferface;
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;  // dut out data
    logic        PREADY;  // dut out data
    // outport signals
    logic [ 3:0] fndCom;  // dut out data
    logic [ 6:0] fndFont;  // dut out data
    logic        dot;

endinterface  //APB_Slave_Intferface

class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;
    integer k = 0;

    function new(mailbox #(transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox   = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int count);
        transaction tr;
            repeat (count)begin
                tr = new();
                //tr.state = (k%3);
                
                if ( !tr.randomize() )begin
                    $error("Randomization fail !!!");
                end
                
                $display("");
                $display("------------------------------------");
                $display(""); 
                
                //$display(tr.state);
                $display("count : %d",k);
                
                tr.display("GEN");

                Gen2Drv_mbox.put(tr);
                #10;
                k = k + 1;
                @(gen_next_event);

            end
    endtask //run
endclass //generator

class driver;
    virtual APB_Slave_Intferface intf;
    mailbox #(transaction) Gen2Drv_mbox;
    transaction tr;

    function new(virtual APB_Slave_Intferface intf, mailbox#(transaction) Gen2Drv_mbox);
        this.intf = intf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
    endfunction  //new()

    task run();
        forever begin
            Gen2Drv_mbox.get(tr);
            tr.display("DRV");
            intf.PADDR   <= tr.PADDR;
            intf.PWDATA  <= tr.PWDATA;
            intf.PWRITE  <= 1'b1;
            intf.PENABLE <= 1'b0;
            intf.PSEL    <= 1'b1;
            @(posedge intf.PCLK);
            intf.PADDR   <= tr.PADDR;
            intf.PWDATA  <= tr.PWDATA;
            intf.PWRITE  <= 1'b1;
            intf.PENABLE <= 1'b1;
            intf.PSEL    <= 1'b1;
            wait (intf.PREADY == 1'b1);
            @(posedge intf.PCLK);
        end
    endtask 
endclass  //driver

class monitor;
    mailbox #(transaction) Mon2SCB_mbox;
    virtual APB_Slave_Intferface intf;
    transaction tr;

    function new(virtual APB_Slave_Intferface intf, mailbox #(transaction) Mon2SCB_mbox);
        this.intf = intf;
        this.Mon2SCB_mbox = Mon2SCB_mbox;    
    endfunction //new()

    task run();
        forever begin
            @(posedge intf.PCLK);
        if (intf.PENABLE && intf.PREADY && intf.PSEL) begin
            tr         = new();
            tr.PADDR   = intf.PADDR;
            tr.PWDATA  = intf.PWDATA;
            tr.PWRITE  = intf.PWRITE;
            tr.PENABLE = intf.PENABLE;
            tr.PSEL    = intf.PSEL;
            tr.PRDATA  = intf.PRDATA;
            tr.PREADY  = intf.PREADY;
            tr.fndCom  = intf.fndCom;
            tr.fndFont = intf.fndFont;
            tr.dot     = intf.dot;
            tr.display("MON");
            Mon2SCB_mbox.put(tr);
        end

        end
    endtask
endclass //monitor

class scoreboard;
    mailbox #(transaction) Mon2SCB_mbox;
    transaction tr;
    event gen_next_event;

    integer success_cnt = 0;
    integer fail_cnt = 0;

    // referenece model
    logic [31:0] refFndReg[0:2];
    logic [7:0] refFndFont[20] = '{
        8'b0100_0000,  
        8'b0111_1001,
        8'b0010_0100,
        8'b0011_0000,
        8'b0001_1001,
        8'b0001_0010,
        8'b0000_0010,
        8'b0101_1000,
        8'b0000_0000,
        8'b0001_0000,
        8'b1100_0000,  
        8'b1111_1001,
        8'b1010_0100,
        8'b1011_0000,
        8'b1001_1001,
        8'b1001_0010,
        8'b1000_0010,
        8'b1101_1000,
        8'b1000_0000,
        8'b1001_0000
    };

    function new(mailbox #(transaction) Mon2SCB_mbox, event gen_next_event);
        this.Mon2SCB_mbox = Mon2SCB_mbox;
        this.gen_next_event = gen_next_event;

        for (int i = 0; i<3; i = i +1 ) begin
            refFndReg[i] = 0;
        end
        refFndReg[0] = 1;
        refFndReg[2] = 1;
    endfunction //new()

    task run();
        forever begin
            Mon2SCB_mbox.get(tr);
            tr.display("SCB");
            if (tr.PWRITE)begin
                refFndReg[tr.PADDR[3:2]] = tr.PWDATA;
                if (refFndFont[refFndReg[1]] == {~tr.dot, tr.fndFont}) begin
                    $display("FND Font PASS!, %h, %b, %h",refFndFont[refFndReg[1]], ~tr.dot, tr.fndFont[6:0]);
                    success_cnt = success_cnt + 1;
                end
                else begin
                    $display("FND Font FAIL!, %h, %b, %h",refFndFont[refFndReg[1]], ~tr.dot, tr.fndFont[6:0]);
                    fail_cnt = fail_cnt + 1;
                end

                if (refFndReg[0] == 0) begin
                    if (4'hf == tr.fndCom) begin
                        $display("FND Enable PASS!");
                        success_cnt = success_cnt + 1;
                    end

                    else begin
                        $display("FND Enable FAIL!");
                        fail_cnt = fail_cnt + 1;
                    end
                end
                else begin
                    if (refFndReg[2][3:0] == ~tr.fndCom[3:0]) begin
                        $display("FND ComPort PASS!, %h, %h",refFndReg[2][3:0], ~tr.fndCom[3:0]);
                        success_cnt = success_cnt + 1;
                    end
                    else begin
                        $display("FND ComPort FAIL!,%h, %h",refFndReg[2][3:0], ~tr.fndCom[3:0]);
                        fail_cnt = fail_cnt + 1;
                    end
                    
                end
                
            end
            else begin
            end
            -> gen_next_event;
        end
    endtask //automatic
endclass //scoreboard


class envirnment;
    mailbox #(transaction) Gen2Drv_mbox;
    mailbox #(transaction) Mon2SCB_mbox;

    generator fnd_gen;
    driver fnd_drv;
    monitor fnd_mon;
    scoreboard fnd_scb;
    event gen_next_event;

    function new(virtual APB_Slave_Intferface fnd_intf);
        this.Gen2Drv_mbox = new();
        this.Mon2SCB_mbox = new();
        this.fnd_gen = new(Gen2Drv_mbox, gen_next_event);
        this.fnd_drv = new(fnd_intf, Gen2Drv_mbox);
        this.fnd_mon = new(fnd_intf, Mon2SCB_mbox);
        this.fnd_scb = new(Mon2SCB_mbox, gen_next_event);
    endfunction  //new()

    task run(int count);
        fork
            fnd_gen.run(count);
            fnd_drv.run();
            fnd_mon.run();
            fnd_scb.run();
        join_any
    endtask  //
endclass  //envirnment

module tb_fndController_APB_Periph ();

    envirnment fnd_env;
    APB_Slave_Intferface intf ();

    always #5 intf.PCLK = ~intf.PCLK;

    FndController_Periph dut (
        // global signal
        .PCLK(intf.PCLK),
        .PRESET(intf.PRESET),
        // APB Interface Signals
        .PADDR(intf.PADDR),
        .PWDATA(intf.PWDATA),
        .PWRITE(intf.PWRITE),
        .PENABLE(intf.PENABLE),
        .PSEL(intf.PSEL),
        .PRDATA(intf.PRDATA),
        .PREADY(intf.PREADY),
        // outport signals
        .fndCom(intf.fndCom),
        .fndFont(intf.fndFont),
        .dot(intf.dot)
    );

    task report();
        $display("============================");
        $display("==       final report     ==");
        $display("============================");
        $display("success test : %d",fnd_env.fnd_scb.success_cnt);
        $display("failed test  : %d",fnd_env.fnd_scb.fail_cnt); 
        $display("total test  : %d",fnd_env.fnd_scb.fail_cnt + fnd_env.fnd_scb.success_cnt);
        $display("============================");
        $display("==   testbench is finish  ==");
        $display("============================");       
    endtask //automatic

    initial begin
        intf.PCLK   = 0;
        intf.PRESET = 1;
        #10 intf.PRESET = 0;
        intf.PADDR   <= 0;
        intf.PWDATA  <= 1'b1;
        intf.PWRITE  <= 1'b1;
        intf.PENABLE <= 1'b0;
        intf.PSEL    <= 1'b1;
        @(posedge intf.PCLK);
        intf.PADDR   <= 0;
        intf.PWDATA  <= 1;
        intf.PWRITE  <= 1'b1;
        intf.PENABLE <= 1'b1;
        intf.PSEL    <= 1'b1;
        wait (intf.PREADY == 1'b1);
        fnd_env = new(intf);
        fnd_env.run(100);
        #30;
        $display("done");
        report();
        $finish;
    end
endmodule

