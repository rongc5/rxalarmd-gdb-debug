#!/bin/bash
###
 # @Author: rong025251 rong025251@163.com
 # @Date: 2024-04-12 20:25:36
 # @LastEditors: rong025251 rong025251@163.com
 # @LastEditTime: 2024-04-15 10:26:45
 # @Description: 用于调试rxalarmd进程的GDB脚本
###

# 默认参数
process_name="test_alarm"
max_breakpoint_hits=1000
max_runtime=0  # 0表示无限制
timestamp=$(date '+%Y%m%d_%H%M%S')
log_file="debug_${process_name}_${timestamp}.log"
gdb_commands_file="${process_name}_debug_commands_${timestamp}.txt"
breakpoints_file=""

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$log_file"
}

# 清理函数
cleanup() {
    log "调试会话结束"
    rm -f "$gdb_commands_file"
    exit 0
}

# 设置信号处理
trap cleanup SIGINT SIGTERM

# 解析命令行参数
while getopts "p:b:h:r:l:" opt; do
    case $opt in
        p) process_name="$OPTARG" ;;
        b) breakpoints_file="$OPTARG" ;;
        h) max_breakpoint_hits="$OPTARG" ;;
        r) max_runtime="$OPTARG" ;;
        l) log_file="$OPTARG" ;;
        ?) echo "Usage: $0 [-p process_name] [-b breakpoints_file] [-h max_hits] [-r max_runtime] [-l log_file]" >&2
           echo "Options:"
           echo "  -p: 进程名称"
           echo "  -b: 断点配置文件"
           echo "  -h: 最大断点触发次数"
           echo "  -r: 最大运行时间(秒)"
           echo "  -l: 日志文件路径"
           exit 1 ;;
    esac
done

# 检查必需参数
if [ -z "$process_name" ] || [ -z "$breakpoints_file" ]; then
    echo "错误: 进程名称和断点配置文件是必需的"
    exit 1
fi

# 重新生成带时间戳的文件名
timestamp=$(date '+%Y%m%d_%H%M%S')
if [[ "$log_file" == "debug_${process_name}_"* ]]; then
    log_file="debug_${process_name}_${timestamp}.log"
fi
gdb_commands_file="${process_name}_debug_commands_${timestamp}.txt"

# 初始化日志文件
echo "开始调试会话 $(date)" > "$log_file"
log "进程名称: $process_name"
log "最大断点触发次数: $max_breakpoint_hits"
log "最大运行时间: $max_runtime"
log "日志文件: $log_file"

# 获取进程PID
process_path="$process_name"
# 检查是否需要从test目录下运行
if [[ ! -f "$process_name" && -f "test/$process_name" ]]; then
    process_path="test/$process_name"
    log "使用测试目录下的程序: $process_path"
fi

pid=$(ps -ef | grep "$process_name" | grep -v grep | grep -v "$0" | awk '{print $2}' | head -1)
if [ -z "$pid" ]; then
    log "未找到进程 $process_name，尝试查找完整路径"
    pid=$(ps -ef | grep "$process_path" | grep -v grep | grep -v "$0" | awk '{print $2}' | head -1)
    if [ -z "$pid" ]; then
        log "错误: 未找到进程 $process_name 或 $process_path"
        exit 1
    fi
fi
log "找到进程 $process_name, PID: $pid"

# 创建GDB命令文件
{
    # 设置基本选项
    echo "set pagination off"
    echo "set confirm off"
    echo "set debuginfod enabled off"
    
    # 附加到进程
    echo "attach $pid"
    
    # 设置多线程调试选项（在attach之后）
    echo "set print thread-events on"  # 显示线程事件
    echo "set print elements 0"        # 显示完整的字符串
    echo "set print pretty on"         # 格式化结构体输出
    echo "set scheduler-locking off"   # 初始状态下不锁定线程
    
    # 初始化计数器和开始时间
    echo "set \$count = 0"
    echo "set \$start_time = time(0)"
    
    # 从断点配置文件添加断点
    while IFS= read -r line || [ -n "$line" ]; do
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        # 解析断点配置
        if [[ "$line" =~ ^([^:]+):([0-9]+)[[:space:]]*(.*)?$ ]]; then
            file="${BASH_REMATCH[1]}"
            line_num="${BASH_REMATCH[2]}"
            rest="${BASH_REMATCH[3]}"
            
            # 解析条件和打印命令
            condition=""
            print_cmds=()
            
            if [[ "$rest" =~ ^([^|]*)\|(.*)$ ]]; then
                condition_part="${BASH_REMATCH[1]}"
                print_part="${BASH_REMATCH[2]}"
                
                if [[ "$condition_part" =~ if[[:space:]]+(.+) ]]; then
                    condition="${BASH_REMATCH[1]}"
                fi
                
                IFS=';' read -ra print_cmds <<< "$print_part"
            else
                if [[ "$rest" =~ if[[:space:]]+(.+) ]]; then
                    condition="${BASH_REMATCH[1]}"
                fi
            fi
            
            # 设置断点
            echo "break $file:$line_num"
            [ -n "$condition" ] && echo "condition \$bpnum $condition"
            
            echo "commands"
            echo "silent"
            
            # 多线程锁定：在断点触发时锁定其他线程
            echo "set scheduler-locking on"
            
            echo "set \$count = \$count + 1"
            echo "shell echo \"============================================\" >> $log_file"
            echo "shell echo \"[断点触发 #\$count] 时间: \$(date '+%Y-%m-%d %H:%M:%S')\" >> $log_file"
            echo "shell echo \"文件: $file\" >> $log_file"
            echo "shell echo \"行号: $line_num\" >> $log_file"
            echo "shell echo \"线程ID: \$_thread\" >> $log_file"
            [ -n "$condition" ] && echo "shell echo \"触发条件: $condition\" >> $log_file"
            
            # 执行用户定义的打印命令
            if [ ${#print_cmds[@]} -gt 0 ]; then
                echo "shell echo \"\" >> $log_file"
                echo "shell echo \"变量值:\" >> $log_file"
                for cmd in "${print_cmds[@]}"; do
                    cmd=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if [ -n "$cmd" ]; then
                        echo "shell echo \"执行: $cmd\" >> $log_file"
                        echo "set logging file $log_file"
                        echo "set logging on"
                        echo "set logging redirect on"
                        echo "$cmd"
                        echo "set logging off"
                    fi
                done
            fi
            
            # 打印调用栈
            echo "shell echo \"\" >> $log_file"
            echo "shell echo \"调用栈(最近3层):\" >> $log_file"
            echo "shell gdb -q -batch -p $pid -ex 'thread \$_thread' -ex 'backtrace 3' 2>/dev/null | tail -n +3 >> $log_file"
            
            # 多线程解锁：打印完成后解锁其他线程
            echo "set scheduler-locking off"
            
            # 检查运行时间限制
            if [ "$max_runtime" -gt 0 ]; then
                echo "if time(0) - \$start_time >= $max_runtime"
                echo "  shell echo \"\" >> $log_file"
                echo "  shell echo \"已达到最大运行时间 $max_runtime 秒，退出GDB\" >> $log_file"
                echo "  quit"
                echo "end"
            fi
            
            # 检查触发次数限制
            echo "if \$count >= $max_breakpoint_hits"
            echo "  shell echo \"\" >> $log_file"
            echo "  shell echo \"已达到 $max_breakpoint_hits 次触发限制，退出GDB\" >> $log_file"
            echo "  quit"
            echo "end"
            
            echo "shell echo \"============================================\" >> $log_file"
            echo "continue"
            echo "end"
        fi
    done < "$breakpoints_file"

    # 添加调试信息验证
    echo "shell echo \"\" >> $log_file"
    echo "shell echo \"=== 断点信息 ===\" >> $log_file"
    echo "shell gdb -q -batch -p $pid -ex 'info breakpoints' >> $log_file 2>&1"
    echo "shell echo \"=== 断点信息结束 ===\" >> $log_file"
    echo "continue"

} > "$gdb_commands_file"

# 启动GDB调试会话
log "使用配置文件: $gdb_commands_file"
log "开始GDB调试会话..."

# 显示GDB命令内容以便调试
echo "=== GDB命令文件内容 ===" >> "$log_file"
cat "$gdb_commands_file" >> "$log_file"
echo "=== GDB命令文件内容结束 ===" >> "$log_file"

# 显示当前工作目录
log "当前工作目录: $(pwd)"
log "断点配置文件内容:"
cat "$breakpoints_file" >> "$log_file"

if [ ! -f "$gdb_commands_file" ]; then
    log "错误：GDB命令文件未创建成功！"
    exit 1
fi

# 使用-q (quiet)和-batch选项确保GDB不会进入交互模式
gdb -q -batch -p $pid -x "$gdb_commands_file" 2>&1 | tee -a "$log_file"

# 检查GDB是否成功执行
if [ $? -ne 0 ]; then
    log "警告：GDB可能未正常退出"
fi

# 清理并退出
cleanup 