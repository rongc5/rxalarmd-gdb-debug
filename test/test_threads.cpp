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
        
        // BREAKPOINT_1: �߳�ִ�е�
        volatile int dummy1 = 1;  // ��ֹ�������Ż�
        
        int result = i * id;
        
        // BREAKPOINT_2: ��������
        volatile int dummy2 = 2;  // ��ֹ�������Ż�
        
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
}

int main() {
    std::cout << "Program started" << std::endl;
    std::vector<std::thread> threads;
    
    // ����3�������߳�
    for (int i = 1; i <= 3; ++i) {
        // BREAKPOINT_3: �̴߳�����
        volatile int dummy3 = 3;  // ��ֹ�������Ż�
        
        std::cout << "Creating thread " << i << std::endl;
        threads.emplace_back(worker, i);
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    // �ȴ������߳����
    for (auto& t : threads) {
        t.join();
    }
    
    std::cout << "Program finished" << std::endl;
    return 0;
} 