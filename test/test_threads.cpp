#include <iostream>
#include <thread>
#include <chrono>
#include <vector>
#include <mutex>

std::mutex cout_mutex;

void worker(int id) {
    for (int i = 0; i < 3; ++i) {
        {
            std::lock_guard<std::mutex> lock(cout_mutex);
            std::cout << "Thread " << id << " count: " << i << std::endl;
        }
        
        // BREAKPOINT_1: 线程执行点
        volatile int dummy1 = 1;  // 防止编译器优化
        
        int result = i * id;
        
        // BREAKPOINT_2: 计算结果点
        volatile int dummy2 = 2;  // 防止编译器优化
        
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
}

int main() {
    std::cout << "Program started" << std::endl;
    std::vector<std::thread> threads;
    
    // 创建3个工作线程
    for (int i = 1; i <= 3; ++i) {
        // BREAKPOINT_3: 线程创建点
        volatile int dummy3 = 3;  // 防止编译器优化
        
        std::cout << "Creating thread " << i << std::endl;
        threads.emplace_back(worker, i);
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    // 等待所有线程完成
    for (auto& t : threads) {
        t.join();
    }
    
    std::cout << "Program finished" << std::endl;
    return 0;
} 