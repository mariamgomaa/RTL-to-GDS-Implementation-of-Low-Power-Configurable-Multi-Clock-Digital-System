module strt_check (
    input wire sampled_bit,
    input wire strt_check_en,

    output wire strt_glitch
);
    assign strt_glitch = (strt_check_en) ? sampled_bit : 0  ;
endmodule