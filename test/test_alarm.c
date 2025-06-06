#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

// �澯���ݽṹ
typedef struct {
    int m_type;                 // �澯����
    int m_reasonCode;           // ԭ����
    char m_alarmText[256];      // �澯�ı�
    time_t m_timestamp;         // ʱ���
    char m_description[512];    // ����
} AlarmData;

// �澯��Ϣ�ṹ
typedef struct {
    AlarmData m_Data;
} AlarmMsg;

// ȫ�ֱ���
AlarmMsg g_alarmMsg;

// ����澯����
void handleAlarm(AlarmMsg* msg) {
    printf("Processing alarm - Type: %d, Reason: %d\n", 
           msg->m_Data.m_type, 
           msg->m_Data.m_reasonCode);
}

// ����澯
void processAlarm(int type, int reasonCode) {
    g_alarmMsg.m_Data.m_type = type;
    g_alarmMsg.m_Data.m_reasonCode = reasonCode;
    g_alarmMsg.m_Data.m_timestamp = time(NULL);
    
    // �����������ò�ͬ�ĸ澯��Ϣ
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

    // ����������Ҫ���öϵ�ĵط�
    handleAlarm(&g_alarmMsg);  // �кŻ��� 57
}

int main() {
    srand(time(NULL));
    
    printf("Alarm service started...\n");
    
    // ����ѭ����ģ����������澯
    while(1) {
        // ���� 1004 ���͸澯��reasonCode >= 13
        processAlarm(1004, 13 + (rand() % 5));
        sleep(2);

        // ���� 1009 ���͸澯��reasonCode >= 3
        processAlarm(1009, 3 + (rand() % 3));
        sleep(2);

        // �����������͸澯
        processAlarm(1005, 1 + (rand() % 5));
        sleep(2);
    }
    
    return 0;
} 