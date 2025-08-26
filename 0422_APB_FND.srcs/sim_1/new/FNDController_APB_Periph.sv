`timescale 1ns / 1ps

class transaction; // 입력으로 들어가는 값 정의
    //APB Interface Signals
    rand logic [ 3:0] PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE;
    rand logic        PENABLE;
    rand logic        PSEL;
    logic [31:0] PRDATA; //dut out data
    logic        PREADY; //dut out data
    //output signals
    logic [ 3:0] fndCom; //dut out data
    logic [ 7:0] fndFont;//dut out data

    constraint c_paddr {PADDR inside {4'h0, 4'h4, 4'h8};}
    constraint c_wdata { PWDATA <10; }

    task display(string name);
        $display("[%s] PADDR = %h, PWDATA = %h, PWRITE = %h, PENABLE = %h, PSEL = %h, PREADY = %h, PRDATA = %h, fndCom = %h, fndFont = %h",  
        name, PADDR, PWDATA, PWRITE, PENABLE, PSEL,  PREADY, PRDATA, fndCom, fndFont);
        
        // name     : 출력 라벨
        // PADDR    : APB 주소
        // PWDATA   : 쓰기 데이터
        // PWRITE   : 쓰기 여부
        // PENABLE  : 전송 유효 신호
        // PSEL     : 선택 신호
        // PREADY   : 슬레이브 응답
        // PRDATA   : 읽기 응답 데이터
        // fndCom   : 선택된 세그먼트 자리
        // fndFont  : 출력된 세그먼트 데이터

    endtask 

endclass //transaction

interface APB_Slave_Interface;
    logic        PCLK;
    logic        PRESET;
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA; //dut out data
    logic        PREADY; //dut out data
    //output signals
    logic [ 3:0] fndCom; //dut out data
    logic [ 7:0] fndFont;//dut out data

endinterface //APB_Slave_Interface

class generator;  //transaction 인스턴스화하기
    mailbox #(transaction) Gen2Drv_mbox; //reference 담을 변수
    event gen_next_event;

    function new(mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction //new()

    task run (int repeat_counter); //c언어의 함수랑 비슷함 
        transaction fnd_tr; //handler
        repeat(repeat_counter) begin
            fnd_tr = new(); //make instance
            if(!fnd_tr.randomize()) $error("Randomization fail"); //에러발생하면 멈춤
            fnd_tr.display("GEN");//에러가 아니면 이 줄 실행
            Gen2Drv_mbox.put(fnd_tr); //mailbox에 transaction 값 put하기
            @(gen_next_event); //wait event from driver
        end
    endtask 
endclass //generator

class driver;
    virtual APB_Slave_Interface fnd_interf;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;
    transaction fnd_tr;

    function new(virtual APB_Slave_Interface fnd_interf,
                mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.fnd_interf = fnd_interf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction //new()

    task run();
        forever begin
            //mailbox에 있는 값 handler로 가져오기
            Gen2Drv_mbox.get(fnd_tr);
            fnd_tr.display("DRV"); //받은 데이터 값 보여주기
            @(posedge fnd_interf.PCLK);
            // 입력 값으로 넣어주기
            fnd_interf.PADDR    <= fnd_tr.PADDR;
            fnd_interf.PWDATA   <= fnd_tr.PWDATA;
            fnd_interf.PWRITE   <= 1'b1;
            fnd_interf.PENABLE  <= 1'b0;
            fnd_interf.PSEL     <= 1'b1;
            @(posedge fnd_interf.PCLK);
            // 입력 값으로 넣어주기
            fnd_interf.PADDR    <= fnd_tr.PADDR;
            fnd_interf.PWDATA   <= fnd_tr.PWDATA;
            fnd_interf.PWRITE   <= 1'b1;
            fnd_interf.PENABLE  <= 1'b1;
            fnd_interf.PSEL     <= 1'b1;
            wait(fnd_interf.PREADY == 1'b1);
            @(posedge fnd_interf.PCLK);
            @(posedge fnd_interf.PCLK);
            @(posedge fnd_interf.PCLK);// clk 2번 기다리기
            -> gen_next_event; //event trigger
        end
    endtask 

endclass //driver

class monitor;
    
    function new();
        
    endfunction //new()
endclass //monitor

class envirnment; //env에서 gen, mailbox 실체화하기
    mailbox #(transaction) Gen2Drv_mbox;
    generator fnd_gen;
    driver fnd_drv;
    event gen_next_event;

    function new(virtual APB_Slave_Interface fnd_interf);
        Gen2Drv_mbox = new();
        this.fnd_gen = new(Gen2Drv_mbox, gen_next_event);
        this.fnd_drv = new(fnd_interf, Gen2Drv_mbox, gen_next_event);
        
    endfunction //new()

    task run (int count);
        fork
            fnd_gen.run(count);
            fnd_drv.run();
        join_any;
    endtask //run

endclass //envirnment
 
    //mailbox #(transaction) Gen2Drv_mbox;
module TB_fndcontroller_APB_Periph();


    envirnment fnd_env;
    APB_Slave_Interface fnd_interf();

    always #5 fnd_interf.PCLK = ~fnd_interf.PCLK;

FndController_Periph dut(
    // global signal
    .PCLK(fnd_interf.PCLK),
    .PRESET(fnd_interf.PRESET),
    //APB Interface signals
    .PADDR(fnd_interf.PADDR),
    .PWDATA(fnd_interf.PWDATA),
    .PWRITE(fnd_interf.PWRITE),
    .PENABLE(fnd_interf.PENABLE),
    .PSEL(fnd_interf.PSEL),
    .PRDATA(fnd_interf.PRDATA),
    .PREADY(fnd_interf.PREADY),
    //outport signals
    .fndCom(fnd_interf.fndCom),
    .fndFont(fnd_interf.fndFont)
);

    initial begin
        fnd_interf.PCLK = 0; fnd_interf.PRESET = 1;
        #10 fnd_interf.PRESET = 0;
        fnd_env = new(fnd_interf); //intf를 env에 연결
        fnd_env.run(10);
        #30;
        $finish;
    end
endmodule
