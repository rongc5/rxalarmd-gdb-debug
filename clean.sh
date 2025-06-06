#!/bin/bash
# ����ű� - ����ɾ�����Թ����в�������ʱ�ļ�

echo "������ʱ��־�ļ�..."
find . -name "debug_*.log" -type f -delete
find . -name "simple_debug_*.log" -type f -delete
find . -name "test_*.log" -type f -delete
find . -name "test_output.log" -type f -delete
find . -name "test_debug_*.log" -type f -delete
find . -name "test_log.txt" -type f -delete

echo "����GDB�����ļ�..."
find . -name "*_debug_commands_*.txt" -type f -delete
find . -name "simple_gdb_commands_*.txt" -type f -delete

echo "���������ʱ���..."
find . -name "test_alarm_debug_commands_*.txt" -type f -delete

echo "ɾ�����Խű��Ͳ���Ҫ�Ĳ����ļ�..."
# ɾ��test_��ͷ�Ĳ���Ҫ�Ĳ��Խű������������Ĳ��Գ���
rm -f test_debug.sh
rm -f test_output.log
rm -f test_threads_debug.log

# rxalarmd��صļ򻯲��԰汾
rm -f rxalarmd_gdb_enhanced_simple.sh

# ɾ������test_breakpoints��ص������ļ�
find . -name "test_breakpoints*.conf" -type f -delete
find . -name "new_breakpoints.conf" -type f -delete

# ɾ���������ɵĶ������ļ�
echo "ɾ������Ķ������ļ�..."
rm -f test/test_alarm
rm -f test/test_alarm_cpp
rm -f test/test_alarm_mt
rm -f test/test_threads
rm -rf test/*.dSYM

echo "�����ļ��ѱ�����test/Ŀ¼:"
echo "  - test/test_alarm.c/.cpp      - ���Ը澯���ɳ���Դ��"
echo "  - test/test_alarm_mt.c        - ���̲߳��Գ���Դ��"
echo "  - test/test_threads.cpp       - �̲߳��Գ���Դ��"
echo "  - test/Makefile               - ���Գ������ű�"

echo "������Գ���:"
echo "  cd test && make               - �������в��Գ���"
echo "  cd test && make test_alarm    - ������test_alarm"
echo "  cd test && make clean         - ��������ļ�"

echo "������ɣ�" 