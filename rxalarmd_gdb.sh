#!/bin/bash

# 设置要监控的进程名
PROCESS_NAME="rxhis"

# 设置断点触发次数限制
MAX_BREAKPOINT_HITS=1000

# 根据进程名动态生成日志文件和GDB命令文件路径
LOG_FILE=~/${PROCESS_NAME}_breakpoints1.log
GDB_COMMANDS_FILE=/tmp/${PROCESS_NAME}_gdb_commands1.txt

# 检查进程是否存在并获取PID
PROCESS_PID=$(pgrep "$PROCESS_NAME")
if [ -z "$PROCESS_PID" ]; then
    echo "错误：未找到 $PROCESS_NAME 进程！"
    exit 1
fi

# 告知用户脚本开始运行
echo "开始监控 $PROCESS_NAME 进程(PID: $PROCESS_PID)"
echo "日志将保存在: $LOG_FILE"
echo "达到 $MAX_BREAKPOINT_HITS 次触发后自动退出"
echo "-------------------------------------------"

# 清空旧的日志文件
echo "===== GDB调试会话开始于 $(date) =====" > "$LOG_FILE"
echo "附加到进程 $PROCESS_PID..." >> "$LOG_FILE"

# 创建GDB命令文件
cat > "$GDB_COMMANDS_FILE" << EOF
set breakpoint pending on
set pagination off
set confirm off
set height 0
set width 0
set logging file "$LOG_FILE"
set logging on

# 初始化计数器
set \$count = 0

# 附加到进程
attach $PROCESS_PID

# 设置断点条件
# hdrmsgrecv.cpp 断点
break hdrmsgrecv.cpp:347 if pAlarmMsg->data.m_type == 1004 && pAlarmMsg->data.m_reasonCode >= 13
break hdrmsgrecv.cpp:347 if pAlarmMsg->data.m_type == 1009 && pAlarmMsg->data.m_reasonCode >= 3

# hdralarmthr.cpp 断点
break hdralarmthr.cpp:56 if msg.data.m_type == 1004 && msg.data.m_reasonCode >= 13
break hdralarmthr.cpp:56 if msg.data.m_type == 1009 && msg.data.m_reasonCode >= 3

# 为 hdrmsgrecv.cpp 断点添加命令
commands 1 2
  # 增加计数器
  set \$count = \$count + 1
  
  # 显示计数
  printf "断点触发次数: %d/$MAX_BREAKPOINT_HITS\\n", \$count
  
  # 打印数据
  print pAlarmMsg->data
  p CConsoleApplication::Instance()->CurrentIsMainProcess()
  
  # 检查是否达到触发次数限制
  if \$count >= $MAX_BREAKPOINT_HITS
    printf "已达到 $MAX_BREAKPOINT_HITS 次触发限制，退出GDB\\n"
    shell echo "===== 已达到 $MAX_BREAKPOINT_HITS 次触发限制，GDB调试会话结束于 \$(date) =====" >> "$LOG_FILE"
    quit
  end
  
  # 继续执行
  continue
end

# 为 hdralarmthr.cpp 断点添加命令
commands 3 4
  # 增加计数器
  set \$count = \$count + 1
  
  # 显示计数
  printf "断点触发次数: %d/$MAX_BREAKPOINT_HITS\\n", \$count
  
  # 打印数据
  print msg.data
  p CConsoleApplication::Instance()->CurrentIsMainProcess()
  
  # 检查是否达到触发次数限制
  if \$count >= $MAX_BREAKPOINT_HITS
    printf "已达到 $MAX_BREAKPOINT_HITS 次触发限制，退出GDB\\n"
    shell echo "===== 已达到 $MAX_BREAKPOINT_HITS 次触发限制，GDB调试会话结束于 \$(date) =====" >> "$LOG_FILE"
    quit
  end
  
  # 继续执行
  continue
end

# 开始执行
continue

# 确保退出
quit
EOF

# 使用GDB运行命令文件
gdb -q -batch -x "$GDB_COMMANDS_FILE"

# 记录会话结束信息
echo "===== GDB调试会话已结束于 $(date) =====" >> "$LOG_FILE"

# 清理临时文件
rm -f "$GDB_COMMANDS_FILE"

echo "GDB已退出，查看日志: $LOG_FILE"
exit 0 