#!/bin/bash
# 清理脚本 - 用于删除调试过程中产生的临时文件

echo "清理临时日志文件..."
find . -name "debug_*.log" -type f -delete
find . -name "simple_debug_*.log" -type f -delete
find . -name "test_*.log" -type f -delete
find . -name "test_output.log" -type f -delete
find . -name "test_debug_*.log" -type f -delete
find . -name "test_log.txt" -type f -delete

echo "清理GDB命令文件..."
find . -name "*_debug_commands_*.txt" -type f -delete
find . -name "simple_gdb_commands_*.txt" -type f -delete

echo "清理调试临时输出..."
find . -name "test_alarm_debug_commands_*.txt" -type f -delete

echo "删除测试脚本和不需要的测试文件..."
# 删除test_开头的不需要的测试脚本，但保留核心测试程序
rm -f test_debug.sh
rm -f test_output.log
rm -f test_threads_debug.log

# rxalarmd相关的简化测试版本
rm -f rxalarmd_gdb_enhanced_simple.sh

# 删除所有test_breakpoints相关的配置文件
find . -name "test_breakpoints*.conf" -type f -delete
find . -name "new_breakpoints.conf" -type f -delete

# 删除编译生成的二进制文件
echo "删除编译的二进制文件..."
rm -f test/test_alarm
rm -f test/test_alarm_cpp
rm -f test/test_alarm_mt
rm -f test/test_threads
rm -rf test/*.dSYM

echo "测试文件已保留在test/目录:"
echo "  - test/test_alarm.c/.cpp      - 测试告警生成程序源码"
echo "  - test/test_alarm_mt.c        - 多线程测试程序源码"
echo "  - test/test_threads.cpp       - 线程测试程序源码"
echo "  - test/Makefile               - 测试程序编译脚本"

echo "编译测试程序:"
echo "  cd test && make               - 编译所有测试程序"
echo "  cd test && make test_alarm    - 仅编译test_alarm"
echo "  cd test && make clean         - 清理编译文件"

echo "清理完成！" 