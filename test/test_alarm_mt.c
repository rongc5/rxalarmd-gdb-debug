#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <pthread.h>

// �澯���ݽṹ
struct AlarmData {
    int m_type;                 // �澯����
    int m_reasonCode;           // ԭ����
    char m_alarmText[256];      // �澯�ı�
    time_t m_timestamp;         // ʱ���
    char m_description[256];    // ����
    int m_severity;             // ���س̶�
    pthread_t thread_id;        // �߳�ID
};

// �澯��Ϣ�ṹ
struct AlarmMsg {
    struct AlarmData m_Data;
};

// ����澯����
void handleAlarm(struct AlarmMsg* alarmMsg) {
    printf("Thread %lu - Processing alarm - Type: %d, Reason: %d\n", 
           alarmMsg->m_Data.thread_id, 
           alarmMsg->m_Data.m_type, 
           alarmMsg->m_Data.m_reasonCode);
}

// ����澯
void processAlarm(int type, int reasonCode, pthread_t tid) {
    struct AlarmMsg alarmMsg;
    alarmMsg.m_Data.m_type = type;
    alarmMsg.m_Data.m_reasonCode = reasonCode;
    alarmMsg.m_Data.m_timestamp = time(NULL);
    alarmMsg.m_Data.thread_id = tid;
    
    // �����������ò�ͬ�ĸ澯��Ϣ
    switch(type) {
        case 1004:
            strcpy(alarmMsg.m_Data.m_alarmText, "Critical System Alert");
            strcpy(alarmMsg.m_Data.m_description, "System resource critical");
            alarmMsg.m_Data.m_severity = 1;
            break;
        case 1009:
            strcpy(alarmMsg.m_Data.m_alarmText, "Network Connection Alert");
            strcpy(alarmMsg.m_Data.m_description, "Network connectivity issues");
            alarmMsg.m_Data.m_severity = 2;
            break;
        default:
            strcpy(alarmMsg.m_Data.m_alarmText, "General Alert");
            strcpy(alarmMsg.m_Data.m_description, "Unknown issue detected");
            alarmMsg.m_Data.m_severity = 3;
    }

    // ����������Ҫ���öϵ�ĵط�
    handleAlarm(&alarmMsg);  // �кŻ��� 71
}

// �̺߳���
void* alarm_thread(void* arg) {
    int thread_num = *(int*)arg;
    pthread_t tid = pthread_self();
    
    while(1) {
        // �����̺߳����ɲ�ͬ���͵ĸ澯
        switch(thread_num) {
            case 0:
                // ��һ���߳�����1004���͸澯
                processAlarm(1004, 13 + (rand() % 5), tid);
                break;
            case 1:
                // �ڶ����߳�����1009���͸澯
                processAlarm(1009, 3 + (rand() % 3), tid);
                break;
            case 2:
                // �������߳�����1005���͸澯
                processAlarm(1005, 1 + (rand() % 5), tid);
                break;
        }
        usleep(500000 + (rand() % 1000000)); // ����ӳ�0.5-1.5��
    }
    return NULL;
}

#define NUM_THREADS 3

int main() {
    pthread_t threads[NUM_THREADS];
    int thread_nums[NUM_THREADS];
    int i;
    
    srand(time(NULL));
    printf("Multi-threaded alarm service started...\n");
    
    // ��������߳�
    for(i = 0; i < NUM_THREADS; i++) {
        thread_nums[i] = i;
        if(pthread_create(&threads[i], NULL, alarm_thread, &thread_nums[i]) != 0) {
            printf("Failed to create thread %d\n", i);
            return 1;
        }
    }
    
    // �ȴ��߳̽�����ʵ���ϲ��������
    for(i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    
    return 0;
} 