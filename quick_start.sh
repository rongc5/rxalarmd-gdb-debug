#!/bin/bash
# �������Žű�

echo "=== rxalarmd GDB���Խű��������� ==="
echo

# ����Ƿ�����ȷĿ¼
if [ ! -f "rxalarmd_gdb_enhanced.sh" ]; then
    echo "����������Ŀ��Ŀ¼���д˽ű�"
    exit 1
fi

echo "1. ��Ŀ�ļ����..."
echo "? ���ű�: $([ -f rxalarmd_gdb_enhanced.sh ] && echo "����" || echo "ȱʧ")"
echo "? �ϵ�����: $([ -f breakpoints.conf ] && echo "����" || echo "ȱʧ")"
echo "? ��������: $([ -f test_breakpoints.conf ] && echo "����" || echo "ȱʧ")"
echo "? ���Գ���Ŀ¼: $([ -d test ] && echo "����" || echo "ȱʧ")"
echo

echo "2. Ȩ�޼��..."
if [ "$(id -u)" = "0" ]; then
    echo "? ��rootȨ������"
else
    echo "? ��ǰ��root�û���������Ҫ����ptraceȨ��"
    echo "  ����: echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope"
fi
echo

echo "3. ʹ��ѡ�"
echo "a) ���Խű����ܣ��Ƽ����֣�"
echo "b) ����rxalarmd����"
echo "c) �鿴������Ϣ"
echo "d) �˳�"
echo

read -p "��ѡ�� (a/b/c/d): " choice

case $choice in
    a|A)
        echo
        echo "=== ���Խű����� ==="
        
        # �����Գ���
        if [ ! -f "test/test_alarm" ]; then
            echo "������Գ���..."
            cd test && make test_alarm && cd .. || {
                echo "����ʧ�ܣ�������뻷��"
                exit 1
            }
        fi
        
        # �������Գ���
        echo "�������Գ���..."
        nohup ./test/test_alarm > test_alarm.log 2>&1 &
        test_pid=$!
        echo "���Գ���PID: $test_pid"
        
        # �ȴ���������
        sleep 2
        
        # ������
        if ! kill -0 $test_pid 2>/dev/null; then
            echo "���Գ�������ʧ��"
            exit 1
        fi
        
        echo "���е��Խű�..."
        echo "����: ./rxalarmd_gdb_enhanced.sh -p test_alarm -b test_breakpoints.conf -h 3 -r 30"
        echo
        
        # ����Ȩ�ޣ������Ҫ��
        if [ "$(id -u)" != "0" ]; then
            echo "��������ptraceȨ��..."
            echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope >/dev/null 2>&1 || {
                echo "Ȩ������ʧ�ܣ����ֶ�����: echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope"
            }
        fi
        
        # ���е���
        ./rxalarmd_gdb_enhanced.sh -p test_alarm -b test_breakpoints.conf -h 3 -r 30
        
        # ����
        echo "������Խ���..."
        kill $test_pid 2>/dev/null || killall test_alarm 2>/dev/null
        
        echo "�鿴���ɵ���־�ļ�:"
        ls -la debug_test_alarm_*.log 2>/dev/null || echo "û���ҵ���־�ļ�"
        ;;
        
    b|B)
        echo
        echo "=== ����rxalarmd���� ==="
        
        # ���rxalarmd����
        pid=$(pgrep rxalarmd | head -1)
        if [ -z "$pid" ]; then
            echo "����δ�ҵ�rxalarmd����"
            echo "��ȷ��rxalarmd��������"
            exit 1
        fi
        
        echo "�ҵ�rxalarmd���̣�PID: $pid"
        echo
        
        # ���ϵ�����
        if [ ! -f "breakpoints.conf" ]; then
            echo "���󣺶ϵ������ļ� breakpoints.conf ������"
            exit 1
        fi
        
        echo "�ϵ������ļ�����:"
        head -10 breakpoints.conf
        echo
        
        read -p "������������ (Ĭ��10): " hits
        read -p "����ʱ������/�� (Ĭ��300): " runtime
        
        hits=${hits:-10}
        runtime=${runtime:-300}
        
        echo "���е��Խű�..."
        echo "����: ./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h $hits -r $runtime"
        echo
        
        if [ "$(id -u)" = "0" ]; then
            ./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h $hits -r $runtime
        else
            sudo ./rxalarmd_gdb_enhanced.sh -p rxalarmd -b breakpoints.conf -h $hits -r $runtime
        fi
        
        echo "�鿴���ɵ���־�ļ�:"
        ls -la debug_rxalarmd_*.log 2>/dev/null || echo "û���ҵ���־�ļ�"
        ;;
        
    c|C)
        echo
        echo "=== ������Ϣ ==="
        ./rxalarmd_gdb_enhanced.sh -h 2>/dev/null || {
            echo "�����÷���"
            echo "./rxalarmd_gdb_enhanced.sh -p ������ -b �ϵ������ļ� [ѡ��]"
            echo
            echo "ѡ�"
            echo "  -p: ��������"
            echo "  -b: �ϵ������ļ�"
            echo "  -h: ���ϵ㴥������"
            echo "  -r: �������ʱ��(��)"
            echo "  -l: ��־�ļ�·��"
        }
        echo
        echo "������Ϣ��鿴:"
        echo "  - README.md: �����ĵ�"
        echo "  - ʹ��ָ��.md: ��ϸʹ��˵��"
        echo "  - ��������Ա���.md: ����˵��"
        ;;
        
    d|D)
        echo "�˳�"
        exit 0
        ;;
        
    *)
        echo "��Чѡ��"
        exit 1
        ;;
esac

echo
echo "=== ��� ==="
echo "��лʹ��rxalarmd GDB���Խű���" 