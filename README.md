<!--
 * @Author: zhangming025251 rongc5@users.noreply.github.com
 * @Date: 2025-04-12 18:00:13
 * @LastEditors: zhangming025251 rongc5@users.noreply.github.com
 * @LastEditTime: 2025-04-15 13:42:00
 * @FilePath: /��ͷ��agc ����/README.md
 * @Description: ����Ĭ������,������`customMade`, ��koroFileHeader�鿴���� ��������: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# rxalarmd GDB���Խű�

һ�������Զ����ӵ�rxalarmd���̲����ض��澯����ʱ���������Ϣ�Ľű����ߡ��ű����������ϵ㣬��¼�澯���飬���ṩ�����õ����в�����

## ��������

- �Զ����ӵ������е�rxalarmd����
- ֧�ֶϵ������ļ���������öϵ������ʹ�ӡ��Ϣ
- ����ض��澯���ͺ�ԭ���루��ͨ���ϵ������ļ��Զ��壩
- ��¼��ϸ�ĸ澯��Ϣ�͵�������
- �����õĶϵ㴥������������ʱ������
- ��������־��¼��ʱ���
- ֧�ֶ��̻߳����µĶϵ㲶��

## Ŀ¼�ṹ

```
gdb_test/
������ breakpoints.conf             - �ϵ������ļ�
������ clean.sh                     - ������ʱ�ļ��Ľű�
������ README.md                    - ���ĵ�
������ rxalarmd_gdb_enhanced.sh     - ��ǿ��GDB���Խű�
������ rxalarmd_gdb.sh              - ԭʼ��GDB���Խű�
������ rxshut                       - rxshut����
������ rxshut.sh                    - rxshut�ű�
������ SUMMARY.md                   - ��Ŀ�ܽ�
������ test/                        - ��������ļ�Ŀ¼
��   ������ Makefile                 - ���Գ������ű�
��   ������ test_alarm.c             - ���Ը澯C����Դ��
��   ������ test_alarm.cpp           - ���Ը澯C++����Դ��
��   ������ test_alarm_mt.c          - ���̲߳��Գ���Դ��
��   ������ test_threads.cpp         - �̲߳��Գ���Դ��
������ ʹ��˵��.md                  - ����ʹ��˵��
```

## �ű��汾

�����������汾�Ľű���

1. **ԭʼ�汾 (rxalarmd_gdb.sh)**���������ܰ汾��ֱ���ڽű������öϵ�
2. **��ǿ�汾 (rxalarmd_gdb_enhanced.sh)**��֧���ⲿ�ϵ������ļ����ṩ������ѡ��

## ��ǿ�汾ʹ�÷���

### ������ѡ��

��ǿ��ű�֧������������ѡ�

```bash
./rxalarmd_gdb_enhanced.sh [-p process_name] [-b breakpoints_file] [-h max_hits] [-r max_runtime] [-l log_file]
```

- `-p`: �������ƣ�Ĭ��Ϊ"test_alarm"��
- `-b`: �ϵ������ļ������������
- `-h`: ���ϵ㴥��������Ĭ��Ϊ1000��
- `-r`: �������ʱ��(��)��0��ʾ�����ƣ�
- `-l`: ��־�ļ�·��

ʾ����
```bash
./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h 10 -r 300 -l debug_rxalarmd_$(date +%Y%m%d_%H%M%S).log
```

### �ϵ������ļ���ʽ

�ϵ������ļ�ʹ�����¸�ʽ��

```
# ע����
�ļ���:�к� if ���� | ��ӡ����1; ��ӡ����2; ...
```

- `�ļ���:�к�`��ָ���ϵ�λ��
- `if ����`����ѡ��ָ���ϵ㴥������
- `| ��ӡ����1; ��ӡ����2; ...`����ѡ��ָ���ϵ㴥��ʱҪִ�еĴ�ӡ����

ʾ����

```
# ���1004���͸澯��ԭ����>=13
alarmservice.cpp:244 if alarmMsg.m_Data.m_type == 1004 && alarmMsg.m_Data.m_reasonCode >= 13 | print alarmMsg.m_Data; print alarmMsg.m_Data.m_reasonCode; print alarmMsg.m_Data.m_alarmText

# ���1009���͸澯��ԭ����>=3
alarmservice.cpp:244 if alarmMsg.m_Data.m_type == 1009 && alarmMsg.m_Data.m_reasonCode >= 3 | print alarmMsg.m_Data.m_type; print alarmMsg.m_Data.m_reasonCode
```

### ��־���

��־�ļ�����������Ϣ��

- �ϵ㴥��������ʱ���
- �ϵ������ļ����к�
- �߳�ID
- ��������
- ����ֵ�����ݶϵ������ļ����壩
- ����ջ�����3�㣩
- ����ʱ��ͳ��

## ��������в��Գ���

���Գ���Դ��λ��testĿ¼�£�ʹ���ṩ��Makefile���б��룺

```bash
# �������Ŀ¼
cd gdb_test/test

# �������в��Գ���
make

# ����ֻ�����ض��Ĳ��Գ���
make test_alarm
make test_alarm_cpp
make test_alarm_mt
make test_threads

# ����������ɵ��ļ�
make clean
```

������ɺ����в��Գ���ʹ��GDB���ԣ�

```bash
# ���벢���и澯���Գ���
cd gdb_test/test
make test_alarm
cd ..
./rxalarmd_gdb_enhanced.sh -p test_alarm -b breakpoints.conf -h 10 -r 30 -l debug_test_$(date +%Y%m%d_%H%M%S).log
```

## ԭʼ�汾ʹ�÷���

1. ȷ���Ѱ�װGDB���Թ���
2. ���ؽű�������ִ��Ȩ�ޣ�

   ```bash
   chmod +x rxalarmd_gdb.sh
   ```

3. ȷ��rxalarmd������������
4. ִ�нű���

   ```bash
   sudo ./rxalarmd_gdb.sh
   ```

   > ע�⣺������Ҫ���ӵ�ϵͳ���̣��ű�ͨ����Ҫʹ��rootȨ�޻�sudoִ��

5. �ű����ں�̨��ظ澯�������������ĸ澯����ʱ���¼�����Ϣ
6. ������ʱ��Ctrl+C�жϽű�ִ��

## ����GDB����Ȩ��

����ĳЩϵͳ��������Ҫ����ptraceȨ�޲���ʹGDB�������ӵ����̣�

```bash
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
```

## ��������ļ�

�����ṩ������ű��������Ŀ¼�е���ʱ�ļ���

```bash
# ��������ű�
./clean.sh
```

�⽫ɾ��������ʱ��־�ļ��͵��������ļ����Լ��������ɵĶ������ļ���������Դ����������ļ���

## �����ų�

����ű�����ʱ�������⣬�������¼��㣺

1. ȷ��Ŀ������Ƿ���������
   ```bash
   pgrep [������]
   ```

2. ȷ�������㹻��Ȩ�޸��ӵ�����
   ```bash
   sudo ./rxalarmd_gdb_enhanced.sh -p [������] -b [�ϵ������ļ�]
   ```

3. ���GDB�Ƿ��Ѱ�װ
   ```bash
   which gdb
   ```

4. ȷ�϶ϵ������ļ��е��ļ�·����ʵ�����ƥ��
   
5. ��������޷����ӵ����̵����⣬��������ptraceȨ��
   ```bash
   echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
   ```

6. ���ϵ������ļ���ʽ�Ƿ���ȷ

## ����ע������

1. �ڷǽ���ģʽ��ʹ��GDBʱ��ȷ�����б�Ҫ�����ö��ڸ��ӵ�����֮ǰ���
2. �ʵ�����������⣬ȷ����־�ļ��Ŀɶ���
3. ����ʹ��ptrace������ã�ȷ��GDB�ܹ���ȷ���ӵ�����
4. ������Ҫ��һ���Ż��ϵ������ʹ�ӡ����Ĵ���

## ���ò���

�ű���ͷ���ְ������¿����ò�����

```bash
# �����ò���
MAX_BREAKPOINT_HITS=10      # ���ϵ㴥������
MAX_RUNTIME_SECONDS=1800    # �������ʱ��(��)��Ĭ��30����
LOG_FILE=~/rxalarmd_breakpoints.log  # ��־�ļ�·��
```

�����Ը�����Ҫ�޸���Щֵ��
- `MAX_BREAKPOINT_HITS`: �ﵽ�˴�����ű��Զ��˳�
- `MAX_RUNTIME_SECONDS`: �ű������ʱ�䣨��λ���룩
- `LOG_FILE`: ��־�ļ�����λ��

## ʾ�����

�ɹ�ִ�нű������������������µ������

```
[2023-06-15 14:32:45] ��ʼrxalarmd���ԻỰ
[2023-06-15 14:32:45] -------------------------------------------
[2023-06-15 14:32:45] �ҵ�rxalarmd���̣�PID: 12345
[2023-06-15 14:32:45] ��ʼ���rxalarmd���̣��ϵ�������alarmservice.cpp:244
...

��ʼ���rxalarmd���̣���Ctrl+C�ж�...

[�ϵ㴥�� #1] ʱ��: Thu Jun 15 14:40:23 2023 (����ʱ��: 458��)
...

[2023-06-15 15:32:45] ��������ɣ���鿴��־: ~/rxalarmd_breakpoints.log
[2023-06-15 15:32:45] ���ԻỰ����
[2023-06-15 15:32:45] -------------------------------------------


�ӿڵ��������ȷ���rxlarmd�澯����  �澯���� д��ʵʱ���ͬʱ ����ʷrxhis��һ������


ҵ�����  ͬ������˼ ��ȡ������ʷ����hdralarmbase20250411 ��ʷ���л�ȡ

�����л��ġ� ���ҵ����÷��͸澯�ˡ����ͻ���ʵʱ��澯�� ���� �¼��� �� ����һ����¼������ͬʱ�Ὣ���ݷ��͵���ʷ���� 


----------------------------------------
hdralarmthr.cpp


AlarmLocalMsg msg:
for (int i = 0; i < num; ++i) {
    if (!m_queue->pop(msg))
        break;
    if (m_buff->addMsg(msg) < 0)
        break;
}

locker.unlock();
if (CConsoleApplication::Instance()->CurrentIsMainProcess())
{
    CLogManager::addTimeLog(MID_HISTORY, LOGLVL_DEBUG, 0, "HdrAlarmOccurThr::run(), current Main Process, "
                                                              "begin save Data, Count:%d.", m_buff->GetCurHRecCount());
    m_pPersist->save(m_buff);
    CLogManager::addTimeLog(MID_HISTORY, LOGLVL_DEBUG, 0, "HdrAlarmOccurThr::run(), current Main Process, "
                                                              "end save Data, Count:%d.", m_buff->GetCurHRecCount());
}
else
{
    CLogManager::addTimeLog(MID_HISTORY, LOGLVL_DEBUG, 0, "HdrAlarmOccurThr::run(), current Assistant "
                                                              "Process, Clear Data, Count:%d.", m_buff->GetCurHRecCount());
}
m_buff->ClearBuffData();


----

struct AlarmLocalMsg
{
    char alarmId[HDRALARMID];
    ALARMITEM_DATA data;
    char alarmString[HDRALARMSTRINGMAX];
};



struct ALARMITEM_DATA
{
    RX_Long m_ID STRUCT_ALIGNED;
    rx_short m_type;
    rx_short m_reasonCode;
    SDateTime m_timeStamp;
    rx_short m_alarmMode;
    SDateTime m_ackTime;
    SDateTime m_delTime;
    rx_byte m_delFlag;
    rx_byte m_ackFlag;
    int m_objectID;
    char m_objectName[64];
    float m_objectValue;
    int m_objTabID;
    int m_objNameField;
    int m_refObj1ID;
    char m_refObj1Name[64];
    int m_refObj2ID;
    char m_refObj2Name[64];
    int m_refObj3ID;
    char m_refObj3Name[64];
    int m_refObj4ID;
    char m_refObj4Name[64];
    rx_short m_refObj1TabID;
    rx_short m_refObj2TabID;
    rx_short m_refObj3TabID;
    rx_short m_refObj4TabID;
    char m_comments[256];
    int m_linkForward;
    int m_linkBackward;
    rx_short m_dbID;
    rx_short m_authorityArea;
    int m_priority;
    rx_short m_pointAlarmOptionFlags;
    rx_short m_v2sGroupID;
    rx_byte m_alarmorEvent;
    int m_containerObj1Id;
    char m_containerObj1Name[64];
    int m_containerObj2Id;
    char m_containerObj2Name[64];
    rx_short m_containerObj1TabId;
    rx_short m_containerObj2TabId;
    rx_short m_recoverProcMode;
    rx_short m_ackMode;
    rx_short m_manualDelPermission;
    int m_qualityCode;
};


---

20240414
1���޸�ɱ��˳��
��ɱrxhis
��ɱ������
2��2���Ʊ����滻