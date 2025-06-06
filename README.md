<!--
 * @Author: zhangming025251 rongc5@users.noreply.github.com
 * @Date: 2025-04-12 18:00:13
 * @LastEditors: zhangming025251 rongc5@users.noreply.github.com
 * @LastEditTime: 2025-04-15 13:42:00
 * @FilePath: /马头地agc 警告/README.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# rxalarmd GDB调试脚本

一个用于自动附加到rxalarmd进程并在特定告警触发时捕获调试信息的脚本工具。脚本设置条件断点，记录告警详情，并提供可配置的运行参数。

## 功能特性

- 自动附加到运行中的rxalarmd进程
- 支持断点配置文件，灵活设置断点条件和打印信息
- 监控特定告警类型和原因码（可通过断点配置文件自定义）
- 记录详细的告警信息和调试数据
- 可配置的断点触发次数和运行时间限制
- 完整的日志记录和时间戳
- 支持多线程环境下的断点捕获

## 目录结构

```
gdb_test/
├── breakpoints.conf             - 断点配置文件
├── clean.sh                     - 清理临时文件的脚本
├── README.md                    - 本文档
├── rxalarmd_gdb_enhanced.sh     - 增强版GDB调试脚本
├── rxalarmd_gdb.sh              - 原始版GDB调试脚本
├── rxshut                       - rxshut工具
├── rxshut.sh                    - rxshut脚本
├── SUMMARY.md                   - 项目总结
├── test/                        - 测试相关文件目录
│   ├── Makefile                 - 测试程序编译脚本
│   ├── test_alarm.c             - 测试告警C程序源码
│   ├── test_alarm.cpp           - 测试告警C++程序源码
│   ├── test_alarm_mt.c          - 多线程测试程序源码
│   └── test_threads.cpp         - 线程测试程序源码
└── 使用说明.md                  - 中文使用说明
```

## 脚本版本

现在有两个版本的脚本：

1. **原始版本 (rxalarmd_gdb.sh)**：基础功能版本，直接在脚本中配置断点
2. **增强版本 (rxalarmd_gdb_enhanced.sh)**：支持外部断点配置文件，提供更灵活的选项

## 增强版本使用方法

### 命令行选项

增强版脚本支持以下命令行选项：

```bash
./rxalarmd_gdb_enhanced.sh [-p process_name] [-b breakpoints_file] [-h max_hits] [-r max_runtime] [-l log_file]
```

- `-p`: 进程名称（默认为"test_alarm"）
- `-b`: 断点配置文件（必需参数）
- `-h`: 最大断点触发次数（默认为1000）
- `-r`: 最大运行时间(秒)（0表示无限制）
- `-l`: 日志文件路径

示例：
```bash
./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h 10 -r 300 -l debug_rxalarmd_$(date +%Y%m%d_%H%M%S).log
```

### 断点配置文件格式

断点配置文件使用以下格式：

```
# 注释行
文件名:行号 if 条件 | 打印命令1; 打印命令2; ...
```

- `文件名:行号`：指定断点位置
- `if 条件`：可选，指定断点触发条件
- `| 打印命令1; 打印命令2; ...`：可选，指定断点触发时要执行的打印命令

示例：

```
# 监控1004类型告警且原因码>=13
alarmservice.cpp:244 if alarmMsg.m_Data.m_type == 1004 && alarmMsg.m_Data.m_reasonCode >= 13 | print alarmMsg.m_Data; print alarmMsg.m_Data.m_reasonCode; print alarmMsg.m_Data.m_alarmText

# 监控1009类型告警且原因码>=3
alarmservice.cpp:244 if alarmMsg.m_Data.m_type == 1009 && alarmMsg.m_Data.m_reasonCode >= 3 | print alarmMsg.m_Data.m_type; print alarmMsg.m_Data.m_reasonCode
```

### 日志输出

日志文件包含以下信息：

- 断点触发次数和时间戳
- 断点所在文件和行号
- 线程ID
- 触发条件
- 变量值（根据断点配置文件定义）
- 调用栈（最近3层）
- 运行时间统计

## 编译和运行测试程序

测试程序源码位于test目录下，使用提供的Makefile进行编译：

```bash
# 进入测试目录
cd gdb_test/test

# 编译所有测试程序
make

# 或者只编译特定的测试程序
make test_alarm
make test_alarm_cpp
make test_alarm_mt
make test_threads

# 清理编译生成的文件
make clean
```

编译完成后，运行测试程序并使用GDB调试：

```bash
# 编译并运行告警测试程序
cd gdb_test/test
make test_alarm
cd ..
./rxalarmd_gdb_enhanced.sh -p test_alarm -b breakpoints.conf -h 10 -r 30 -l debug_test_$(date +%Y%m%d_%H%M%S).log
```

## 原始版本使用方法

1. 确保已安装GDB调试工具
2. 下载脚本并赋予执行权限：

   ```bash
   chmod +x rxalarmd_gdb.sh
   ```

3. 确认rxalarmd进程正在运行
4. 执行脚本：

   ```bash
   sudo ./rxalarmd_gdb.sh
   ```

   > 注意：由于需要附加到系统进程，脚本通常需要使用root权限或sudo执行

5. 脚本将在后台监控告警，当符合条件的告警触发时会记录相关信息
6. 可以随时按Ctrl+C中断脚本执行

## 设置GDB调试权限

对于某些系统，可能需要调整ptrace权限才能使GDB正常附加到进程：

```bash
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
```

## 清理测试文件

运行提供的清理脚本清理测试目录中的临时文件：

```bash
# 运行清理脚本
./clean.sh
```

这将删除所有临时日志文件和调试命令文件，以及编译生成的二进制文件，但保留源代码和配置文件。

## 故障排除

如果脚本运行时遇到问题，请检查以下几点：

1. 确认目标进程是否正在运行
   ```bash
   pgrep [进程名]
   ```

2. 确认您有足够的权限附加到进程
   ```bash
   sudo ./rxalarmd_gdb_enhanced.sh -p [进程名] -b [断点配置文件]
   ```

3. 检查GDB是否已安装
   ```bash
   which gdb
   ```

4. 确认断点配置文件中的文件路径与实际情况匹配
   
5. 如果遇到无法附加到进程的问题，尝试设置ptrace权限
   ```bash
   echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
   ```

6. 检查断点配置文件格式是否正确

## 开发注意事项

1. 在非交互模式下使用GDB时，确保所有必要的设置都在附加到进程之前完成
2. 适当处理编码问题，确保日志文件的可读性
3. 考虑使用ptrace相关设置，确保GDB能够正确附加到进程
4. 根据需要进一步优化断点条件和打印命令的处理

## 配置参数

脚本开头部分包含以下可配置参数：

```bash
# 可配置参数
MAX_BREAKPOINT_HITS=10      # 最大断点触发次数
MAX_RUNTIME_SECONDS=1800    # 最大运行时间(秒)，默认30分钟
LOG_FILE=~/rxalarmd_breakpoints.log  # 日志文件路径
```

您可以根据需要修改这些值：
- `MAX_BREAKPOINT_HITS`: 达到此次数后脚本自动退出
- `MAX_RUNTIME_SECONDS`: 脚本最长运行时间（单位：秒）
- `LOG_FILE`: 日志文件保存位置

## 示例输出

成功执行脚本后，您将看到类似以下的输出：

```
[2023-06-15 14:32:45] 开始rxalarmd调试会话
[2023-06-15 14:32:45] -------------------------------------------
[2023-06-15 14:32:45] 找到rxalarmd进程，PID: 12345
[2023-06-15 14:32:45] 开始监控rxalarmd进程，断点设置在alarmservice.cpp:244
...

开始监控rxalarmd进程，按Ctrl+C中断...

[断点触发 #1] 时间: Thu Jun 15 14:40:23 2023 (运行时间: 458秒)
...

[2023-06-15 15:32:45] 调试已完成，请查看日志: ~/rxalarmd_breakpoints.log
[2023-06-15 15:32:45] 调试会话结束
[2023-06-15 15:32:45] -------------------------------------------


接口调用数据先发往rxlarmd告警服务，  告警数据 写入实时库的同时 给历史rxhis发一份数据


业务界面  同他们意思 读取的是历史表中hdralarmbase20250411 历史表中获取

主备切换的。 如果业务调用发送告警了。。就会在实时库告警表 或者 事件表 中 产生一条记录。。。同时会将数据发送到历史程序 


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
1、修改杀掉顺序
先杀rxhis
再杀其他的
2、2进制备份替换