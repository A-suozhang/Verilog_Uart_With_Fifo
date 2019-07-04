# UART_WITH_FIFO
* 利用FPGA实现串口,在串口后端加上了一个fifo(缓冲区)

# 文件
* uart_with_fifo_tx/rx.v  (带fifo的uart)
    * uart_tx/rx (uart实现)
    * baud_gen (产生波特率)
* uart_with_fifo_tx_regs (从特定的寄存器中不断读出值并且通过uart传送)

# 测试
## UART_TEST
* 并不加入fifo,用于测试uart
    * 如果串口RX接受到输入,直接发回串口
    * 如果按键超过0.5s,发送固定数值()
## UART_TEST_TB
* (仿真)
* 正常的串口仿真,写入TX,RX解析出结果
## UART_WITH_FIFO
* 加入了FIFO,完整测试
    * 接受输入的数据,通过fifo
    * 进行数据处理,结束之后写入
    * 通过fifo,串口TX输出
* FLOW:  
    * |Data_IN| > |UART_RX| > |FIFO| > |DATA_PROCESS| > |FIFO| > |UART_TX| > |SERIAL_DATA_OUT|
## UART_WITH_FIFO_TB
* (仿真)
* 先利用uart_with_fifo_tx_regs从一堆特定的regs当中取出数据并通过fifo串口输出
* 然后经过一个自回环的UART_WITH_FIFO,输出RX_SERIAL_DATA
* 输出的RX_SERIAL_DATA利用一个uart_rx解析

