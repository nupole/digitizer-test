add_subdirectory(channel_trigger_n)
add_subdirectory(coincidence)

add_hdl_file(trigger_manager.vhdl PACKAGES trigger_manager_pkg.vhdl
                                  DEPENDENCIES math_pkg
                                               channel_trigger_n
                                               coincidence
                                               edge_detector
                                               timer)
