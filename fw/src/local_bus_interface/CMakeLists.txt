add_subdirectory(transceiver)

add_hdl_file(local_bus_interface.vhdl PACKAGES local_bus_interface_pkg.vhdl
                                      DEPENDENCIES mux
                                                   transceiver)
