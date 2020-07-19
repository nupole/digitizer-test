include_guard()

function(get_hdl_dependencies hdl_file_target_name dependencies)
    set(ret)

    get_target_property(HDL_FILE_DEPENDENCIES ${hdl_file_target_name} HDL_FILE_DEPENDENCIES)

    foreach(HDL_FILE_DEPENDENCY ${HDL_FILE_DEPENDENCIES})
        if(NOT TARGET ${HDL_FILE_DEPENDENCY})
            message(FATAL_ERROR "HDL target doesn't exist: ${HDL_FILE_DEPENDENCY}")
        endif()

        get_hdl_dependencies(${HDL_FILE_DEPENDENCY} HDL_FILE_DEPENDENCY_DEPENDENCIES)
        list(APPEND ret ${HDL_FILE_DEPENDENCY_DEPENDENCIES})
    endforeach()

    list(APPEND ret ${hdl_file_target_name})
    list(REMOVE_DUPLICATES ret)

    set(${dependencies} ${ret} PARENT_SCOPE)
endfunction()
