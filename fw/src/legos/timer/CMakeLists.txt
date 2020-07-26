add_hdl_file(timer.vhdl PACKAGES timer_pkg.vhdl
                        DEPENDENCIES counter
                                     comparator)
