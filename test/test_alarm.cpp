/*
 * @Author: zhangming025251 rongc5@users.noreply.github.com
 * @Date: 2025-04-15 11:14:01
 * @LastEditors: zhangming025251 rongc5@users.noreply.github.com
 * @LastEditTime: 2025-04-15 11:45:17
 * @FilePath: /��ͷ��agc ����/test_alarm.cpp
 * @Description: ����Ĭ������,������`customMade`, ��koroFileHeader�鿴���� ��������: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
#include <iostream>
#include <thread>
#include <chrono>
#include <string>
#include <cstring>
#include <vector>

// �澯���ݽṹ
struct AlarmData {
    int m_type;                 // �澯����
    int m_reasonCode;           // ԭ����
    char m_alarmText[256];      // �澯�ı�
    char m_description[1024];   // ����
    long m_timestamp;           // ʱ���
};

// �澯��Ϣ�ṹ
struct AlarmMsg {
    AlarmData m_Data;
};

AlarmMsg g_alarmMsg;

void setAlarm(int type, int reasonCode, const char* text, const char* desc) {
    g_alarmMsg.m_Data.m_type = type;
    g_alarmMsg.m_Data.m_reasonCode = reasonCode;
    g_alarmMsg.m_Data.m_timestamp = std::time(nullptr);
    strncpy(g_alarmMsg.m_Data.m_alarmText, text, sizeof(g_alarmMsg.m_Data.m_alarmText) - 1);
    strncpy(g_alarmMsg.m_Data.m_description, desc, sizeof(g_alarmMsg.m_Data.m_description) - 1);
    
    // �������öϵ�
    std::cout << "Alarm set: Type=" << type << ", ReasonCode=" << reasonCode << std::endl;
}

void alarmThread(int id) {
    for (int i = 0; i < 3; ++i) {
        switch(id) {
            case 1:
                setAlarm(1004, 13 + i, "Critical Error", "System critical error occurred");
                break;
            case 2:
                setAlarm(1009, 3 + i, "Warning", "System warning detected");
                break;
            case 3:
                setAlarm(1005, 1 + i, "Info", "System status update");
                break;
        }
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
}

int main() {
    std::vector<std::thread> threads;
    
    // ����3���澯�߳�
    for (int i = 1; i <= 3; ++i) {
        threads.emplace_back(alarmThread, i);
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    // �ȴ������߳����
    for (auto& t : threads) {
        t.join();
    }
    
    return 0;
} 