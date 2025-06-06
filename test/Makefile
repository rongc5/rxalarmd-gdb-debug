CC = gcc
CXX = g++
CFLAGS = -g -Wall
CXXFLAGS = -g -Wall -std=c++11 -pthread

# 所有编译目标
all: test_alarm test_alarm_mt test_threads

# 编译C语言版本的test_alarm
test_alarm: test_alarm.c
	$(CC) $(CFLAGS) -o $@ $<

# 编译C++语言版本的test_alarm
test_alarm_cpp: test_alarm.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# 编译多线程版本的test_alarm
test_alarm_mt: test_alarm_mt.c
	$(CC) $(CFLAGS) -pthread -o $@ $<

# 编译线程测试程序
test_threads: test_threads.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# 清理编译生成的文件
clean:
	rm -f test_alarm test_alarm_cpp test_alarm_mt test_threads
	rm -rf *.dSYM

# 安装规则（复制到bin目录，如果需要的话）
install:
	mkdir -p ../bin
	cp test_alarm test_alarm_mt test_threads ../bin/

.PHONY: all clean install 