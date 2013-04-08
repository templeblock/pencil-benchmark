// UjoImro, 2013
// OpenCL code for the CARP Project

#ifndef __ERRORS__HPP__
#define __ERRORS__HPP__

#include <map>
#include <string>
#include <CL/cl.h>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <boost/preprocessor.hpp>

#define PRINT(var)  std::cout << "debug: " << BOOST_PP_STRINGIZE(var) << " = " << var << std::endl

template<class T0>
void
print_image( cv::Mat_<T0> input, std::string name )
{
    std::cout << name << " = [" << std::endl;
    
    for (int q=0; q<input.rows; q++)
    {
        std::cout << "[ ";        
        for (int w=0; w<input.cols; w++)
        {
            std::cout << input(q,w);
            if (w<input.cols-1)
                std::cout << ", ";
            else
                std::cout << " ";
        }

        if (q<input.rows-1)
            std::cout << "], " << std::endl;
        else
            std::cout << "] " << std::endl;
    }

    std::cout << "]" << std::endl;    
} // print_image


namespace carp {

    namespace opencl {
    
        std::map<int, std::string> errors {
            {CL_SUCCESS, "CL_SUCCESS"},
            {CL_DEVICE_NOT_FOUND, "CL_DEVICE_NOT_FOUND"},
            {CL_DEVICE_NOT_AVAILABLE, "CL_DEVICE_NOT_AVAILABLE"},
            {CL_COMPILER_NOT_AVAILABLE, "CL_COMPILER_NOT_AVAILABLE"},
            {CL_MEM_OBJECT_ALLOCATION_FAILURE, "CL_MEM_OBJECT_ALLOCATION_FAILURE"},
            {CL_OUT_OF_RESOURCES, "CL_OUT_OF_RESOURCES"},
            {CL_OUT_OF_HOST_MEMORY, "CL_OUT_OF_HOST_MEMORY"},
            {CL_PROFILING_INFO_NOT_AVAILABLE, "CL_PROFILING_INFO_NOT_AVAILABLE"},
            {CL_MEM_COPY_OVERLAP, "CL_MEM_COPY_OVERLAP"},
            {CL_IMAGE_FORMAT_MISMATCH, "CL_IMAGE_FORMAT_MISMATCH"},
            {CL_IMAGE_FORMAT_NOT_SUPPORTED, "CL_IMAGE_FORMAT_NOT_SUPPORTED"},
            {CL_BUILD_PROGRAM_FAILURE, "CL_BUILD_PROGRAM_FAILURE"},
            {CL_MAP_FAILURE, "CL_MAP_FAILURE"},
            {CL_MISALIGNED_SUB_BUFFER_OFFSET, "CL_MISALIGNED_SUB_BUFFER_OFFSET"},
            {CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST, "CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST"},
            {CL_COMPILE_PROGRAM_FAILURE, "CL_COMPILE_PROGRAM_FAILURE"},
            {CL_LINKER_NOT_AVAILABLE, "CL_LINKER_NOT_AVAILABLE"},
            {CL_LINK_PROGRAM_FAILURE, "CL_LINK_PROGRAM_FAILURE"},
            {CL_DEVICE_PARTITION_FAILED, "CL_DEVICE_PARTITION_FAILED"},
            {CL_KERNEL_ARG_INFO_NOT_AVAILABLE, "CL_KERNEL_ARG_INFO_NOT_AVAILABLE"},
            {CL_INVALID_VALUE, "CL_INVALID_VALUE"},
            {CL_INVALID_DEVICE_TYPE, "CL_INVALID_DEVICE_TYPE"},
            {CL_INVALID_PLATFORM, "CL_INVALID_PLATFORM"},
            {CL_INVALID_DEVICE, "CL_INVALID_DEVICE"},
            {CL_INVALID_CONTEXT, "CL_INVALID_CONTEXT"},
            {CL_INVALID_QUEUE_PROPERTIES, "CL_INVALID_QUEUE_PROPERTIES"},
            {CL_INVALID_COMMAND_QUEUE, "CL_INVALID_COMMAND_QUEUE"},
            {CL_INVALID_HOST_PTR, "CL_INVALID_HOST_PTR"},
            {CL_INVALID_MEM_OBJECT, "CL_INVALID_MEM_OBJECT"},
            {CL_INVALID_IMAGE_FORMAT_DESCRIPTOR, "CL_INVALID_IMAGE_FORMAT_DESCRIPTOR"},
            {CL_INVALID_IMAGE_SIZE, "CL_INVALID_IMAGE_SIZE"},
            {CL_INVALID_SAMPLER, "CL_INVALID_SAMPLER"},
            {CL_INVALID_BINARY, "CL_INVALID_BINARY"},
            {CL_INVALID_BUILD_OPTIONS, "CL_INVALID_BUILD_OPTIONS"},
            {CL_INVALID_PROGRAM, "CL_INVALID_PROGRAM"},
            {CL_INVALID_PROGRAM_EXECUTABLE, "CL_INVALID_PROGRAM_EXECUTABLE"},
            {CL_INVALID_KERNEL_NAME, "CL_INVALID_KERNEL_NAME"},
            {CL_INVALID_KERNEL_DEFINITION, "CL_INVALID_KERNEL_DEFINITION"},
            {CL_INVALID_KERNEL, "CL_INVALID_KERNEL"},
            {CL_INVALID_ARG_INDEX, "CL_INVALID_ARG_INDEX"},
            {CL_INVALID_ARG_VALUE, "CL_INVALID_ARG_VALUE"},
            {CL_INVALID_ARG_SIZE, "CL_INVALID_ARG_SIZE"},
            {CL_INVALID_KERNEL_ARGS, "CL_INVALID_KERNEL_ARGS"},
            {CL_INVALID_WORK_DIMENSION, "CL_INVALID_WORK_DIMENSION"},
            {CL_INVALID_WORK_GROUP_SIZE, "CL_INVALID_WORK_GROUP_SIZE"},
            {CL_INVALID_WORK_ITEM_SIZE, "CL_INVALID_WORK_ITEM_SIZE"},
            {CL_INVALID_GLOBAL_OFFSET, "CL_INVALID_GLOBAL_OFFSET"},
            {CL_INVALID_EVENT_WAIT_LIST, "CL_INVALID_EVENT_WAIT_LIST"},
            {CL_INVALID_EVENT, "CL_INVALID_EVENT"},
            {CL_INVALID_OPERATION, "CL_INVALID_OPERATION"},
            {CL_INVALID_GL_OBJECT, "CL_INVALID_GL_OBJECT"},
            {CL_INVALID_BUFFER_SIZE, "CL_INVALID_BUFFER_SIZE"},
            {CL_INVALID_MIP_LEVEL, "CL_INVALID_MIP_LEVEL"},
            {CL_INVALID_GLOBAL_WORK_SIZE, "CL_INVALID_GLOBAL_WORK_SIZE"},
            {CL_INVALID_PROPERTY, "CL_INVALID_PROPERTY"},
            {CL_INVALID_IMAGE_DESCRIPTOR, "CL_INVALID_IMAGE_DESCRIPTOR"},
            {CL_INVALID_COMPILER_OPTIONS, "CL_INVALID_COMPILER_OPTIONS"},
            {CL_INVALID_LINKER_OPTIONS, "CL_INVALID_LINKER_OPTIONS"},
            {CL_INVALID_DEVICE_PARTITION_COUNT, "CL_INVALID_DEVICE_PARTITION_COUNT"}
        }; // cl_errors

    } // namespace opencl
        
} // namespace carp


 

#endif /* __ERRORS__HPP__ */

// LuM end of file
