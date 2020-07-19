include_guard()

function(get_hdl_sources_from_hdl_dependencies hdl_file_dependencies hdl_file_sources)
    set(ret)

    foreach(HDL_FILE_DEPENDENCY ${hdl_file_dependencies})
            if(NOT TARGET ${HDL_FILE_DEPENDENCY})
                message(FATAL_ERROR "HDL target doesn't exist: ${HDL_FILE_DEPENDENCY}")
            endif()

            get_target_property(HDL_FILE_SOURCES ${HDL_FILE_DEPENDENCY} HDL_FILE_SOURCES)

            list(APPEND ret ${HDL_FILE_SOURCES})
    endforeach()

    list(REMOVE_DUPLICATES ret)

    set(${hdl_file_sources} ${ret} PARENT_SCOPE)
endfunction()
