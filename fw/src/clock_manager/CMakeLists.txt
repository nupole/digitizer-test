add_subdirectory(pll)

add_hdl_file(clock_manager.vhdl DEPENDENCIES pll)
