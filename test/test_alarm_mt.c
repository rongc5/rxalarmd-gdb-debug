#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <pthread.h>

// 告警数据结构
struct AlarmData {
    int m_type;                 // 告警类型
    int m_reasonCode;           // 原因码
    char m_alarmText[256];      // 告警文本
    time_t m_timestamp;         // 时间戳
    char m_description[256];    // 描述
    int m_severity;             // 严重程度
    pthread_t thread_id;        // 线程ID
};

// 告警消息结构
struct AlarmMsg {
    struct AlarmData m_Data;
};

// 处理告警函数
void handleAlarm(struct AlarmMsg* alarmMsg) {
    printf("Thread %lu - Processing alarm - Type: %d, Reason: %d\n", 
           alarmMsg->m_Data.thread_id, 
           alarmMsg->m_Data.m_type, 
           alarmMsg->m_Data.m_reasonCode);
}

// 处理告警
void processAlarm(int type, int reasonCode, pthread_t tid) {
    struct AlarmMsg alarmMsg;
    alarmMsg.m_Data.m_type = type;
    alarmMsg.m_Data.m_reasonCode = reasonCode;
    alarmMsg.m_Data.m_timestamp = time(NULL);
    alarmMsg.m_Data.thread_id = tid;
    
    // 根据类型设置不同的告警信息
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

    // 这里是我们要设置断点的地方
    handleAlarm(&alarmMsg);  // 行号会是 71
}

// 线程函数
void* alarm_thread(void* arg) {
    int thread_num = *(int*)arg;
    pthread_t tid = pthread_self();
    
    while(1) {
        // 根据线程号生成不同类型的告警
        switch(thread_num) {
            case 0:
                // 第一个线程生成1004类型告警
                processAlarm(1004, 13 + (rand() % 5), tid);
                break;
            case 1:
                // 第二个线程生成1009类型告警
                processAlarm(1009, 3 + (rand() % 3), tid);
                break;
            case 2:
                // 第三个线程生成1005类型告警
                processAlarm(1005, 1 + (rand() % 5), tid);
                break;
        }
        usleep(500000 + (rand() % 1000000)); // 随机延迟0.5-1.5秒
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
    
    // 创建多个线程
    for(i = 0; i < NUM_THREADS; i++) {
        thread_nums[i] = i;
        if(pthread_create(&threads[i], NULL, alarm_thread, &thread_nums[i]) != 0) {
            printf("Failed to create thread %d\n", i);
            return 1;
        }
    }
    
    // 等待线程结束（实际上不会结束）
    for(i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    
    return 0;
} 