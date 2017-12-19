module Snake(
	CLK100MHz,
	up,
	down,
	left,
	right,
	vga_r,
	vga_g,
	vga_b,
	vga_hs,
	vga_vs
);

    //Movimiento
    input up;
    input down;
    input left;
    input right;

    //Clock 
    input   CLK100MHz;

    //Salidas de Video
    output [2:0] vga_r;
    output [2:0] vga_g;
    output [1:0] vga_b;
    output vga_hs;
    output vga_vs;

    //Clock de 100mhz a 25mhz
    wire vga_clk;

    DCM_SP #(.CLKFX_DIVIDE(8), .CLKFX_MULTIPLY(2), .CLKIN_PERIOD(10))
    vga_clock_dcm (.CLKIN(CLK100MHz), .CLKFX(vga_clk), .CLKFB(0), .PSEN(0), .RST(0));

    //Registros
    reg [2:0] vga_r_r;
    reg [2:0] vga_g_r;
    reg [1:0] vga_b_r;
    reg vga_hs_r;
    reg vga_vs_r;

    //Outputs = Registros
    assign vga_r = vga_r_r;
    assign vga_g = vga_g_r;
    assign vga_b = vga_b_r;
    assign vga_hs = vga_hs_r;
    assign vga_vs = vga_vs_r;

    //Timers
    reg [7:0] timer_t = 8'b0;
    reg [6:0] timer_2 = 6'b0;
    reg [6:0] timer_3 = 6'b0;
    reg reset = 1;

    //Cont Frames
    reg [9:0] cont_x;
    reg [9:0] cont_y;
    reg [9:0] countv_x;
    reg [9:0] countv_y;

    //Enable Flasg
    reg	disp_en;


    //Reg y Wires para la pos de la Food
    parameter food_size = 3;
    parameter f_init_x = 100;
    parameter f_init_y = 100;
    
    reg[9:0] x;
    reg[9:0] y;
    reg [9:0] f_pos_x;
    reg [9:0] f_pos_y; 
    
    wire [9:0] l_f_pos_x;	
    wire [9:0] r_f_pos_x;
    wire [9:0] u_f_pos_y;
    wire [9:0] d_f_pos_y;
    
    assign l_f_pos_x = f_pos_x - food_size;
    assign r_f_pos_x = f_pos_x + food_size;
    assign u_f_pos_y = f_pos_y - food_size;
    assign d_f_pos_y = f_pos_y + food_size;
    assign f_fig_x = cont_x - l_f_pos_x;
    assign f_fig_y = cont_y - u_f_pos_y;
    
    wire [4:0] f_fig_x;
    wire [4:0] f_fig_y;

    //Reg y Wires para la pos de la snake
    parameter snake_size = 10;
    parameter init_x = 320;
    parameter init_y = 240;
    
    reg [9:0] s_pos_x;
    reg [9:0] s_pos_y;  
    
    wire [9:0] l_s_pos_x;	
    wire [9:0] r_s_pos_x;
    wire [9:0] u_s_pos_y;
    wire [9:0] d_s_pos_y;
    
    assign l_s_pos_x = s_pos_x - snake_size;
    assign r_s_pos_x = s_pos_x + snake_size;
    assign u_s_pos_y = s_pos_y - snake_size;
    assign d_s_pos_y = s_pos_y + snake_size;
    
    reg [19:0] s_figure [0:19];
    reg [5:0]  f_figure [0:5];    
    wire [4:0] s_fig_x;
    wire [4:0] s_fig_y;
    
    assign s_fig_x = cont_x - l_s_pos_x;
    assign s_fig_y = cont_y - u_s_pos_y;

    
    always @ (posedge vga_clk) begin
        if(timer_t > 250) begin
            reset <= 0;
        end
        else begin
            reset <= 1;
            timer_t <= timer_t + 1;
            disp_en <= 0;
            s_pos_x <= init_x;
            s_pos_y <= init_y;
            
            f_pos_x <= f_init_x;
            f_pos_y <= f_init_y;
            x = f_init_x;
            y = f_init_y;
        end
        
        if(reset == 1) begin
            s_figure[0][19:0]  <=	20'b00000000000000000000;
            s_figure[1][19:0]  <=	20'b00000001111100000000;
            s_figure[2][19:0]  <=	20'b00000111111111000000;
            s_figure[3][19:0]  <=	20'b00011111111111110000;
            s_figure[4][19:0]  <=	20'b00111111111111111000;
            s_figure[5][19:0]  <=	20'b00111111111111111000;
            s_figure[6][19:0]  <=	20'b01111111111111111100;
            s_figure[7][19:0]  <=	20'b01111111111111111100;
            s_figure[8][19:0]  <=	20'b11111111111111111110;
            s_figure[9][19:0]  <=	20'b11111111111111111110;
            s_figure[10][19:0] <=	20'b11111111111111111110;
            s_figure[11][19:0] <=	20'b11111111111111111110;
            s_figure[12][19:0] <=	20'b11111111111111111110;
            s_figure[13][19:0] <=	20'b01111111111111111100;
            s_figure[14][19:0] <=	20'b01111111111111111100;    
            s_figure[15][19:0] <=	20'b00111111111111111000;
            s_figure[16][19:0] <=	20'b00111111111111111000;
            s_figure[17][19:0] <=	20'b00011111111111110000;
            s_figure[18][19:0] <=	20'b00000111111111000000;
            s_figure[19][19:0] <=	20'b00000001111100000000;
            
            countv_x <= 0;
            countv_y <= 0;
            vga_hs_r <= 1;
            vga_vs_r <= 0;
            cont_y <= 0;
            cont_x <= 0;
        end
        else begin
            if(countv_x < 800 - 1) begin
                countv_x <= countv_x + 1;
            end
            else begin
                countv_x <= 0;
                if(countv_y < 525 - 1) begin
                    countv_y <= countv_y + 1;
                end
                else begin
                    countv_y <= 0;
                end
            end
        end

        
        //H-Sync
        if(countv_x < 657 || countv_x > 752) begin
            vga_hs_r <= ~0;
        end
        else begin
            vga_hs_r <= 0;
        end

        //V-Sync
        if(countv_y < 490 || countv_y > 492) begin
            vga_vs_r <= ~1;
        end 
        else begin
            vga_vs_r <= 1;
        end

        //Variables que solo se actualizan en la parte visible
        if(countv_x < 640) begin		
            cont_x <= countv_x;
        end
        if(countv_y < 480) begin
            cont_y <= countv_y;
        end
        
        //Sirve solo para generar colores en la parte visible
        if(countv_x < 640 && countv_y < 480) begin
            disp_en <= 1;
        end
        else begin
            disp_en <= 0;
        end
        
        if(disp_en == 1 && reset == 0) begin
            //Borde
            if(cont_y < 3 || cont_x < 3 || cont_y > 476 || cont_x > 636) begin
                vga_r_r <= 0;
                vga_g_r <= 0;
                vga_b_r <= 1;
            end
      
            //Food
            else if(cont_x > l_f_pos_x && cont_x < r_f_pos_x && cont_y > u_f_pos_y && cont_y < d_f_pos_y) begin
                vga_r_r <= 0;
                vga_g_r <= 0;
                vga_b_r <= 0;
            end
            
            //Snake
            else if(cont_x > l_s_pos_x && cont_x < r_s_pos_x && cont_y > u_s_pos_y && cont_y < d_s_pos_y) begin
                if(s_figure[s_fig_y][s_fig_x] == 1) begin
                    vga_r_r <= 1;
                    vga_g_r <= 2;
                    vga_b_r <= 1;
                end
                else begin
                    vga_r_r <= 2;
                    vga_g_r <= 2;
                    vga_b_r <= 1;
                end
            end
            else begin
                vga_r_r <= 2;
                vga_g_r <= 2;
                vga_b_r <= 1;
            end
        end
        
        //Parte no Visible del frame
        else begin
            vga_r_r <= 0;
            vga_g_r <= 0;
            vga_b_r <= 0;
        end
        
        //Movimiento
        if(cont_y == 1 && cont_x == 1) begin
            if(up==0) begin
                if (s_pos_y > snake_size) begin
                    s_pos_y <= s_pos_y - 1;
                end
            end;

            if(down==0) begin
                if (s_pos_y < (480 - 1 - snake_size)) begin
                    s_pos_y <= s_pos_y + 1;
                end
            end;

            if(left==0) begin
                if (s_pos_x > snake_size) begin
                    s_pos_x <= s_pos_x - 1;
                end
            end;
            if(right==0) begin
                if (s_pos_x < (640 - 1 - snake_size)) begin
                    s_pos_x <= s_pos_x + 1;
                end
            end;

        end
        
        //Timers para generar numeros aleatorios para la nueva posicion del food
        if(127 >= timer_2) begin
            timer_2 <= timer_2 + 9;
        end
        else begin 
            timer_2 <= 0;
        end 
        
        if(127 >= timer_3) begin
            timer_3 <= timer_3 + 11;
        end
        else begin 
            timer_3 <= 0;
        end   
        
        //Colisiones
        if((l_s_pos_x +10 > l_f_pos_x && l_s_pos_x -10 < l_f_pos_x) && (u_s_pos_y + 10 > u_f_pos_y && u_s_pos_y - 10 < u_f_pos_y)||
        (r_s_pos_x +10 > r_f_pos_x && r_s_pos_x -10 < r_f_pos_x) && (d_s_pos_y + 10 > d_f_pos_y && d_s_pos_y - 10 < d_f_pos_y)) begin             
            
            if(timer_2 < 64) begin
                f_pos_x <= f_pos_x -timer_3;
            
            end
            else begin 
                f_pos_x <= f_pos_x +timer_3;
            end 
            
            if(timer_2 > 64) begin
                f_pos_y <= f_pos_y +timer_2;
            end
            else begin 
                f_pos_y <= f_pos_y -timer_2;
            end               
            
            if(f_pos_y <= 470) begin
                f_pos_y <= init_y ;
            end
            
            if(f_pos_y <= 10) begin
                f_pos_y <= init_y ;
            end
            
            if(f_pos_x <= 10 ) begin
                f_pos_x <= init_x;
            end
            
            if(f_pos_x >= 630) begin
                f_pos_x <= init_x; 
            end
        end
    end   
endmodule
