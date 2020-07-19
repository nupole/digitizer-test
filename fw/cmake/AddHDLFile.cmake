include_guard()

include(AddLatticeTarget)

function(add_hdl_file hdl_file)
    set(options TOP_FILE)

    set(one_value_keywords LPF_FILE)

    set(multi_value_keywords PACKAGES
                             DEPENDENCIES)

    cmake_parse_arguments(HDL_FILE "${options}" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN})

    set(HDL_FILE_SOURCES)

    if(DEFINED HDL_FILE_PACKAGES)
        foreach(HDL_FILE_PACKAGE ${HDL_FILE_PACKAGES})
            get_filename_component(HDL_FILE_PACKAGE_SOURCE ${HDL_FILE_PACKAGE} REALPATH)

            if(NOT EXISTS ${HDL_FILE_PACKAGE_SOURCE})
                message(FATAL_ERROR "HDL package file doesn't exist: ${HDL_FILE_PACKAGE}")
            endif()

            list(APPEND HDL_FILE_SOURCES ${HDL_FILE_PACKAGE_SOURCE})
        endforeach()
    endif()

    if(NOT DEFINED hdl_file)
        message(FATAL_ERROR "No HDL file provided...")
    endif()

    get_filename_component(HDL_FILE_MAIN_SOURCE ${hdl_file} REALPATH)

    if(NOT EXISTS ${HDL_FILE_MAIN_SOURCE})
        message(FATAL_ERROR "HDL file doesn't exist: ${hdl_file}")
    endif()

    get_filename_component(HDL_FILE_TARGET_NAME ${HDL_FILE_MAIN_SOURCE} NAME_WE)
    list(APPEND HDL_FILE_SOURCES ${HDL_FILE_MAIN_SOURCE})

    add_custom_target(${HDL_FILE_TARGET_NAME} DEPENDS ${HDL_FILE_SOURCES})

    set_target_properties(${HDL_FILE_TARGET_NAME} PROPERTIES HDL_FILE_SOURCES "${HDL_FILE_SOURCES}")
    set_target_properties(${HDL_FILE_TARGET_NAME} PROPERTIES HDL_FILE_DEPENDENCIES "${HDL_FILE_DEPENDENCIES}")

    if(DEFINED HDL_FILE_DEPENDENCIES)
        add_dependencies(${HDL_FILE_TARGET_NAME} ${HDL_FILE_DEPENDENCIES})
    endif()

    if(HDL_FILE_TOP_FILE)
        if(NOT DEFINED HDL_FILE_LPF_FILE)
            message(FATAL_ERROR "No LPF file provided...")
        endif()

        get_filename_component(HDL_FILE_LPF_FILE ${HDL_FILE_LPF_FILE} REALPATH)
        if(NOT EXISTS ${HDL_FILE_LPF_FILE})
            message(FATAL_ERROR "LPF file doesn't exist: ${HDL_FILE_LPF_FILE}")
        endif()

        set_target_properties(${HDL_FILE_TARGET_NAME} PROPERTIES HDL_FILE_LPF_FILE ${HDL_FILE_LPF_FILE})
        add_lattice_target(${HDL_FILE_TARGET_NAME})
    endif()
endfunction()
