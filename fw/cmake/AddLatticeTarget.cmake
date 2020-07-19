include_guard()

include(GetHDLDependencies)
include(GetHDLSourcesFromHDLDependencies)

function(add_lattice_target hdl_file_target_name)
    set(SYNTHESIS_TARGET_NAME "synthesis_${hdl_file_target_name}")
    set(MAP_TARGET_NAME "map_${hdl_file_target_name}")
    set(PAR_TARGET_NAME "par_${hdl_file_target_name}")
    set(BITGEN_TARGET_NAME "bitgen_${hdl_file_target_name}")
    set(LATTICE_TARGET_NAME "lattice_${hdl_file_target_name}")
    set(LATTICE_TARGET_WORKING_DIR ${CMAKE_CURRENT_BINARY_DIR}/lattice_${hdl_file_target_name})

    set(options)

    set(one_value_keywords)

    set(multi_value_keywords)

    cmake_parse_arguments(LATTICE_TARGET "${options}" "${one_value_keywords}" "${multi_value_keywords}")

    get_target_property(HDL_FILE_LPF_FILE ${hdl_file_target_name} HDL_FILE_LPF_FILE)

    get_hdl_dependencies(${hdl_file_target_name} HDL_FILE_TARGET_DEPENDENCIES)
    get_hdl_sources_from_hdl_dependencies("${HDL_FILE_TARGET_DEPENDENCIES}" SYNTHESIS_TARGET_SOURCES)

    set(SYNTHESIS_TARGET_OUTPUTS ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.lsedata
                                 ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.arearep
                                 ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}_lse.twr
                                 ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}_prim.v
                                 ${LATTICE_TARGET_WORKING_DIR}/xxx_lse_sign_file
                                 ${LATTICE_TARGET_WORKING_DIR}/xxx_lse_cp_file_list
                                 ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ngd
                                 ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}_drc.log
                                 ${LATTICE_TARGET_WORKING_DIR}/synthesis.log)

    add_custom_command(OUTPUT ${SYNTHESIS_TARGET_OUTPUTS}
                       COMMAND synthesis -a   MachXO2
                                         -d   LCMXO2-4000HC
                                         -s   6
                                         -t   TQFP144
                                         -top ${hdl_file_target_name}
                                         -vhd ${SYNTHESIS_TARGET_SOURCES}
                                         -vh2008
                                         -frequency 100
                                         -optimization_goal timing
                                         -use_io_reg 1
                                         -lpf 0
                                         -ngd ${hdl_file_target_name}.ngd
                       DEPENDS ${SYNTHESIS_TARGET_SOURCES}
                       WORKING_DIRECTORY ${LATTICE_TARGET_WORKING_DIR}
                       COMMENT "Synthesizing target ${SYNTHESIS_TARGET_NAME}")

    add_custom_target(${SYNTHESIS_TARGET_NAME} ALL DEPENDS ${SYNTHESIS_TARGET_OUTPUTS})

    add_dependencies(${SYNTHESIS_TARGET_NAME} ${hdl_file_target_name})

    set(MAP_TARGET_OUTPUTS ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.hrr
                           ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.prf
                           ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}_map.cam
                           ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.mrp
                           ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}_map.asd
                           ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ncd
                           ${LATTICE_TARGET_WORKING_DIR}/.vdbs/digitizer_rtl.vdb
                           ${LATTICE_TARGET_WORKING_DIR}/.vdbs/dbStat.txt
                           ${LATTICE_TARGET_WORKING_DIR}/.vdbs/digitizer_tech.vdb)

    set(MAP_TARGET_DEPENDENCIES ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ngd
                                ${HDL_FILE_LPF_FILE})

    add_custom_command(OUTPUT ${MAP_TARGET_OUTPUTS}
                       COMMAND map ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ngd
                                   ${HDL_FILE_LPF_FILE}
                                   -a MachXO2
                                   -p LCMXO2-4000HC
                                   -t TQFP144
                                   -s 6
                                   -ioreg b
                                   -pe
                                   -pr ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.prf
                                   -o ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ncd
                       DEPENDS ${MAP_TARGET_DEPENDENCIES}
                       WORKING_DIRECTORY ${LATTICE_TARGET_WORKING_DIR}
                       COMMENT "Mapping target ${MAP_TARGET_NAME}")

    add_custom_target(${MAP_TARGET_NAME} ALL DEPENDS ${MAP_TARGET_OUTPUTS})

    add_dependencies(${MAP_TARGET_NAME} ${SYNTHESIS_TARGET_NAME})

    set(PAR_TARGET_OUTPUTS ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}_par.asd
                           ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.pad
                           ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.par)

    set(PAR_TARGET_DEPENDENCIES ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ncd
                                ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.prf)

    add_custom_command(OUTPUT ${PAR_TARGET_OUTPUTS}
                       COMMAND par -pe
                                   -w
                                   ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ncd
                                   ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ncd
                                   ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.prf
                       DEPENDS ${PAR_TARGET_DEPENDENCIES}
                       WORKING_DIRECTORY ${LATTICE_TARGET_WORKING_DIR}
                       COMMENT "Placing and Routing target ${PAR_TARGET_NAME}")

    add_custom_target(${PAR_TARGET_NAME} ALL DEPENDS ${PAR_TARGET_OUTPUTS})

    add_dependencies(${PAR_TARGET_NAME} ${MAP_TARGET_NAME})

    set(BITGEN_TARGET_OUTPUTS ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.drc
                              ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.jed
                              ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.bgn
                              ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.alt)

    set(BITGEN_TARGET_DEPENDENCIES ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ncd
                                   ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.prf)

    add_custom_command(OUTPUT ${BITGEN_TARGET_OUTPUTS}
                       COMMAND bitgen -jedec
                                      -w
                                      ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.ncd
                                      ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.jed
                                      ${LATTICE_TARGET_WORKING_DIR}/${hdl_file_target_name}.prf
                       DEPENDS ${BITGEN_TARGET_DEPENDENCIES}
                       WORKING_DIRECTORY ${LATTICE_TARGET_WORKING_DIR}
                       COMMENT "Generating Bitfile for target ${BITGEN_TARGET_NAME}")

    add_custom_target(${BITGEN_TARGET_NAME} ALL DEPENDS ${BITGEN_TARGET_OUTPUTS})

    add_dependencies(${BITGEN_TARGET_NAME} ${PAR_TARGET_NAME})

    add_custom_target(${LATTICE_TARGET_NAME} ALL)

    add_dependencies(${LATTICE_TARGET_NAME} ${BITGEN_TARGET_NAME})

    file(MAKE_DIRECTORY ${LATTICE_TARGET_WORKING_DIR})
endfunction()
