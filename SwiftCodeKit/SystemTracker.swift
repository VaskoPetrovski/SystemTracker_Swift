import Foundation

public typealias MemoryUsage = (used: UInt64, total: UInt64)
public typealias CpuUsage = (cpuUsage: Double,activeCores : Int)

public struct SystemTracker {
    
    
    public init() {}
 
    /// Calculates the total CPU usage of the application across all available cores.
    ///
    /// This function iterates through all threads of the current task (application) to accumulate CPU usage.
    /// Each thread's CPU time is obtained and summed up to calculate the total CPU usage.
    ///
    /// - Returns: A `CpuUsage` structure containing the total CPU usage percentage and the number of active processor cores.
    ///
    /// Note: The total CPU usage can exceed 100% on multi-core devices since it aggregates CPU usage across all cores.
    /// For example, on a quad-core device, the maximum reported CPU usage could theoretically reach 400% if all cores are fully utilized.
    public static func cpuUsage() -> CpuUsage {
            var totalUsageOfCPU: Double = 0.0
            var threadsList: thread_act_array_t?
            var threadsCount = mach_msg_type_number_t(0)
            let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
                return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                    task_threads(mach_task_self_, $0, &threadsCount)
                }
            }
            
            if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
                for index in 0..<threadsCount {
                    var threadInfo = thread_basic_info()
                    var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                    let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                            thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                        }
                    }
                    
                    guard infoResult == KERN_SUCCESS else {
                        break
                    }
                    
                    let threadBasicInfo = threadInfo as thread_basic_info
                    if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                        totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
                    }
                }
            }
            
            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        return (totalUsageOfCPU, ProcessInfo.processInfo.activeProcessorCount)
        }
    
    
    /// Calculates the CPU usage of the main thread of the application.
    ///
    /// This function checks if it's running on the main thread and then proceeds to measure the CPU usage
    /// specifically for the main thread. It's essential because CPU usage metrics might be required
    /// for performance analysis or optimization while ensuring the UI remains responsive.
    ///
    /// - Returns: A `CpuUsage` structure containing the CPU usage percentage of the main thread
    ///   and the number of active processor cores. If the function is called from a non-main thread,
    ///   it returns 0.0 as CPU usage to indicate that the measurement is not applicable.
    public static func cpuUsageMainThread() -> CpuUsage {
        // Early return if not on the main thread, since we only want to measure main thread CPU usage
        guard Thread.isMainThread else {
            return ( 0.0, ProcessInfo.processInfo.activeProcessorCount)
        }

        var totalUsageOfCPU: Double = 0.0
        var threadInfo = thread_basic_info()
        var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
        
        // Use mach_thread_self() to get the current thread (which is the main thread in this case)
        let thread = mach_thread_self()
        
        let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                thread_info(thread, thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
            }
        }
        
        // Deallocate the port right allocated by mach_thread_self()
        mach_port_deallocate(mach_task_self_, thread)

        if infoResult == KERN_SUCCESS {
            if threadInfo.flags & TH_FLAGS_IDLE == 0 {
                totalUsageOfCPU = (Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0)
            }
        } else {
            print("Failed to get thread info: \(infoResult)")
        }

        return ( totalUsageOfCPU,ProcessInfo.processInfo.activeProcessorCount)
    }
    
    /// Retrieves the current memory usage of the application along with the total physical memory of the device.
    ///
    /// This function gathers memory usage information by querying the Mach task's basic information,
    /// which includes the resident memory size. This size represents the amount of physical memory
    /// occupied by the application.
    ///
    /// - Returns: A `MemoryUsage` tuple containing the used memory in bytes and the total physical memory of the device in bytes.
        public static func memoryUsage() -> MemoryUsage {

            let totalMemory = ProcessInfo.processInfo.physicalMemory
            
         
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4 // Divide by 4 because it's in units of 4 bytes
            
            // Attempt to get the current task's information
            let result: kern_return_t = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                }
            }
            
            var usedMemory: UInt64 = 0
            if result == KERN_SUCCESS {
                usedMemory = UInt64(info.resident_size) // Resident size is the actual physical memory being used
            } else {
                print("Error with task_info(): \(String(describing: result))")
            }
            
            return (usedMemory, totalMemory)
        }
}





