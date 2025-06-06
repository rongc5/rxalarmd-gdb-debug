#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

// 告警数据结构
typedef struct {
    int m_type;                 // 告警类型
    int m_reasonCode;           // 原因码
    char m_alarmText[256];      // 告警文本
    time_t m_timestamp;         // 时间戳
    char m_description[512];    // 描述
} AlarmData;

// 告警消息结构
typedef struct {
    AlarmData m_Data;
} AlarmMsg;

// 全局变量
AlarmMsg g_alarmMsg;

// 处理告警函数
void handleAlarm(AlarmMsg* msg) {
    printf("Processing alarm - Type: %d, Reason: %d\n", 
           msg->m_Data.m_type, 
           msg->m_Data.m_reasonCode);
}

// 处理告警
void processAlarm(int type, int reasonCode) {
    g_alarmMsg.m_Data.m_type = type;
    g_alarmMsg.m_Data.m_reasonCode = reasonCode;
    g_alarmMsg.m_Data.m_timestamp = time(NULL);
    
    // 根据类型设置不同的告警信息
    switch(type) {
        case 1004:
            snprintf(g_alarmMsg.m_Data.m_alarmText, sizeof(g_alarmMsg.m_Data.m_alarmText), 
                    "Critical alarm type 1004");
            snprintf(g_alarmMsg.m_Data.m_description, sizeof(g_alarmMsg.m_Data.m_description), 
                    "System critical error detected");
            break;
        case 1009:
            snprintf(g_alarmMsg.m_Data.m_alarmText, sizeof(g_alarmMsg.m_Data.m_alarmText), 
                    "Warning alarm type 1009");
            snprintf(g_alarmMsg.m_Data.m_description, sizeof(g_alarmMsg.m_Data.m_description), 
                    "System warning condition");
            break;
        case 1005:
            snprintf(g_alarmMsg.m_Data.m_alarmText, sizeof(g_alarmMsg.m_Data.m_alarmText), 
                    "Info alarm type 1005");
            snprintf(g_alarmMsg.m_Data.m_description, sizeof(g_alarmMsg.m_Data.m_description), 
                    "System information message");
            break;
    }

    // 这里是我们要设置断点的地方
    handleAlarm(&g_alarmMsg);  // 行号会是 57
}

int main() {
    srand(time(NULL));
    
    printf("Alarm service started...\n");
    
    // 无限循环，模拟持续产生告警
    while(1) {
        // 生成 1004 类型告警，reasonCode >= 13
        processAlarm(1004, 13 + (rand() % 5));
        sleep(2);

        // 生成 1009 类型告警，reasonCode >= 3
        processAlarm(1009, 3 + (rand() % 3));
        sleep(2);

        // 生成其他类型告警
        processAlarm(1005, 1 + (rand() % 5));
        sleep(2);
    }
    
    return 0;
} 