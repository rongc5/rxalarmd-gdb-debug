#!/bin/bash
# 快速入门脚本

echo "=== rxalarmd GDB调试脚本快速入门 ==="
echo

# 检查是否在正确目录
if [ ! -f "rxalarmd_gdb_enhanced.sh" ]; then
    echo "错误：请在项目根目录运行此脚本"
    exit 1
fi

echo "1. 项目文件检查..."
echo "? 主脚本: $([ -f rxalarmd_gdb_enhanced.sh ] && echo "存在" || echo "缺失")"
echo "? 断点配置: $([ -f breakpoints.conf ] && echo "存在" || echo "缺失")"
echo "? 测试配置: $([ -f test_breakpoints.conf ] && echo "存在" || echo "缺失")"
echo "? 测试程序目录: $([ -d test ] && echo "存在" || echo "缺失")"
echo

echo "2. 权限检查..."
if [ "$(id -u)" = "0" ]; then
    echo "? 以root权限运行"
else
    echo "? 当前非root用户，可能需要设置ptrace权限"
    echo "  命令: echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope"
fi
echo

echo "3. 使用选项："
echo "a) 测试脚本功能（推荐新手）"
echo "b) 调试rxalarmd进程"
echo "c) 查看帮助信息"
echo "d) 退出"
echo

read -p "请选择 (a/b/c/d): " choice

case $choice in
    a|A)
        echo
        echo "=== 测试脚本功能 ==="
        
        # 检查测试程序
        if [ ! -f "test/test_alarm" ]; then
            echo "编译测试程序..."
            cd test && make test_alarm && cd .. || {
                echo "编译失败，请检查编译环境"
                exit 1
            }
        fi
        
        # 启动测试程序
        echo "启动测试程序..."
        nohup ./test/test_alarm > test_alarm.log 2>&1 &
        test_pid=$!
        echo "测试程序PID: $test_pid"
        
        # 等待程序启动
        sleep 2
        
        # 检查进程
        if ! kill -0 $test_pid 2>/dev/null; then
            echo "测试程序启动失败"
            exit 1
        fi
        
        echo "运行调试脚本..."
        echo "命令: ./rxalarmd_gdb_enhanced.sh -p test_alarm -b test_breakpoints.conf -h 3 -r 30"
        echo
        
        # 设置权限（如果需要）
        if [ "$(id -u)" != "0" ]; then
            echo "尝试设置ptrace权限..."
            echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null 2>&1 || {
                echo "权限设置失败，请手动运行: echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope"
            }
        fi
        
        # 运行调试
        ./rxalarmd_gdb_enhanced.sh -p test_alarm -b test_breakpoints.conf -h 3 -r 30
        
        # 清理
        echo "清理测试进程..."
        kill $test_pid 2>/dev/null || killall test_alarm 2>/dev/null
        
        echo "查看生成的日志文件:"
        ls -la debug_test_alarm_*.log 2>/dev/null || echo "没有找到日志文件"
        ;;
        
    b|B)
        echo
        echo "=== 调试rxalarmd进程 ==="
        
        # 检查rxalarmd进程
        pid=$(pgrep rxalarmd | head -1)
        if [ -z "$pid" ]; then
            echo "错误：未找到rxalarmd进程"
            echo "请确保rxalarmd正在运行"
            exit 1
        fi
        
        echo "找到rxalarmd进程，PID: $pid"
        echo
        
        # 检查断点配置
        if [ ! -f "breakpoints.conf" ]; then
            echo "错误：断点配置文件 breakpoints.conf 不存在"
            exit 1
        fi
        
        echo "断点配置文件内容:"
        head -10 breakpoints.conf
        echo
        
        read -p "触发次数限制 (默认10): " hits
        read -p "运行时间限制/秒 (默认300): " runtime
        
        hits=${hits:-10}
        runtime=${runtime:-300}
        
        echo "运行调试脚本..."
        echo "命令: ./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h $hits -r $runtime"
        echo
        
        if [ "$(id -u)" = "0" ]; then
            ./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h $hits -r $runtime
        else
            sudo ./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h $hits -r $runtime
        fi
        
        echo "查看生成的日志文件:"
        ls -la debug_rxalarmd_*.log 2>/dev/null || echo "没有找到日志文件"
        ;;
        
    c|C)
        echo
        echo "=== 帮助信息 ==="
        ./rxalarmd_gdb_enhanced.sh -h 2>/dev/null || {
            echo "基本用法："
            echo "./rxalarmd_gdb_enhanced.sh -p 进程名 -b 断点配置文件 [选项]"
            echo
            echo "选项："
            echo "  -p: 进程名称"
            echo "  -b: 断点配置文件"
            echo "  -h: 最大断点触发次数"
            echo "  -r: 最大运行时间(秒)"
            echo "  -l: 日志文件路径"
        }
        echo
        echo "更多信息请查看:"
        echo "  - README.md: 完整文档"
        echo "  - 使用指南.md: 详细使用说明"
        echo "  - 需求符合性报告.md: 功能说明"
        ;;
        
    d|D)
        echo "退出"
        exit 0
        ;;
        
    *)
        echo "无效选择"
        exit 1
        ;;
esac

echo
echo "=== 完成 ==="
echo "感谢使用rxalarmd GDB调试脚本！" 