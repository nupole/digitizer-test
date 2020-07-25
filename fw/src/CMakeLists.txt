add_subdirectory(packages)
add_subdirectory(legos)
add_subdirectory(clock_manager)
add_subdirectory(local_bus_interface)
add_subdirectory(trigger_manager)

add_hdl_file(digitizer.vhdl TOP_FILE
                            LPF_FILE digitizer.lpf
                            DEPENDENCIES clock_manager
                                         trigger_manager
                                         local_bus_interface)
