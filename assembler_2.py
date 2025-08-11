import re
import tkinter as tk
from tkinter import filedialog



opcode_map = {
    'nop'    : '00000',
    'cmp'    : '00000',
    'clr'    : '00000',
    'add'    : '00001',
    'mov'    : '00001',
    'inc'    : '00001',
    'sub'    : '00010',
    'dec'    : '00010',
    'neg'    : '00010',
    'mul'    : '00011',
    'div'    : '00100',
    'mod'    : '00101',
    'not'    : '00110',
    'and'    : '00111',
    'or'     : '01000',
    'xor'    : '01001',
    'shl'    : '01010',
    'shr'    : '01011',
    'jmp'    : '01100',
    'je'     : '01101',
    'jne'    : '01110',
    'jl'     : '01111',
    'jle'    : '10000',
    'jg'     : '10001',
    'jge'    : '10010',
    'call'   : '10011',
    'ret'    : '10100',
    'push'   : '10101',
    'pop'    : '10110',
    'sw'     : '10111',
    'lw'     : '11000',
    'sd'     : '11001',
    'ld'     : '11010',
    'in'     : '11011',
    'sc'     : '11100',
    'draw'   : '11101',
    'console': '11110',
    'halt'   : '11111'
}

# 寄存器映射
register_map = {f'r{i}': i for i in range(32)}



const_table = {}  # 存储 CONST 表
label_table = {}  # 存储 LABEL 表



def is_immediate(token):
    """判断操作数是否为立即数"""
    immediate_pattern = re.compile(r"^-?(0b[01]+|0x[0-9A-Fa-f]+|0o[0-7]+|\d+)$")
    return bool(immediate_pattern.match(token))


def parse_const_definition(line, line_num):
    """解析 const 定义"""
    parts = line.strip().split()

    if len(parts) != 4 or parts[2] != '=':
        raise ValueError(f"第{line_num}行错误：const 语法错误，应为 'const 符号名 = 值' 格式\n> {line}")

    symbol = parts[1]
    val_token = parts[3]

    if symbol in const_table:
        raise ValueError(f"第{line_num}行错误：CONST '{symbol}' 重复定义\n> {line}")

    const_table[symbol] = val_token



def parse_label_definition(line, line_num, instr_addr):
    """解析 label 定义"""
    label, _, _ = line.partition(':')
    label = label.strip()
    if not label:
        raise ValueError(f"第{line_num}行错误：label 语法错误，标签名不能为空\n> {line}")
    if label in label_table:
        raise ValueError(f"第{line_num}行错误：label '{label}' 重复定义\n> {line}")
    label_table[label] = instr_addr
    return instr_addr


def parse_const_label(lines):
    """第一轮解析：解析 const 和 label 定义"""
    instr_addr = 0
    line_map = []  # 原始汇编代码行数
    assembly_lines = []  # 去掉首尾空格、空行、注释行、 CONST 和 LABEL 定义行的汇编代码

    # 处理首尾空格、空行和注释行
    for line_num, line in enumerate(lines, 1):
        line = line.strip()
        line_map.append(line_num)
        if not line or line.startswith(';'):
            continue

        # const 行
        if line.startswith('const'):
            parse_const_definition(line, line_num)

        # label 行
        elif ':' in line:
            instr_addr = parse_label_definition(line, line_num, instr_addr)

        # 普通指令行
        else:
            parts = line.split()
            op = parts[0]
            operands = parts[1:]
            if operands and operands[-1] in const_table:
                operands[-1] = const_table[operands[-1]]
            if operands and is_immediate(operands[-1]):
                imm = int(operands[-1], 0)
                if imm < 0 or imm >= 32768:
                    instr_addr += 1
            if op in ['je', 'jne', 'jl', 'jle', 'jg', 'jge']:
                instr_addr += 1
            instr_addr += 1
            assembly_lines.append(line)
    return assembly_lines, line_map


def replace_const_label(lines):
    """第二轮解析：替换 const 和 label，顺便去除方括号"""
    resolved_lines = []
    for _, line in enumerate(lines, 1):
        parts = line.split()
        op = parts[0]
        operands = parts[1:]
        replaced_operands = []
        for token in operands:
            # 去掉操作数前后方括号（如果有）
            if token.startswith('[') and token.endswith(']'):
                token = token[1:-1].strip()
            if token in const_table:
                replaced_operands.append(const_table[token])
            elif token in label_table:
                replaced_operands.append(label_table[token])
            else:
                replaced_operands.append(token)
        replaced_line = ' '.join([op] + [str(token) for token in replaced_operands])
        resolved_lines.append(replaced_line)
    return resolved_lines


def parse_register(token, line_num):
    """解析寄存器编号"""
    if token in register_map:
        return register_map[token]
    raise ValueError(f"第{line_num}行错误：无效寄存器名 '{token}'")


def parse_instruction(lines, line_map, assembly_lines):
    """第三轮解析：处理指令并生成机器码"""
    machine_code = []
    final_lines = []

    for i, line in enumerate(lines):
        line_num = line_map[i]
        parts = line.split()
        op = parts[0]
        operands = parts[1:]

        if op in opcode_map:
            opcode = opcode_map[op]
            
            # 处理条件跳转指令
            if op in ['je', 'jne', 'jl', 'jle', 'jg', 'jge']:
                if len(operands) != 3:
                    raise ValueError(f"第{line_num}行错误：{op} 指令需要三个操作数")
                rs1 = parse_register(operands[0], line_num)
                jmp_addr = int(operands[2], 0)
                jmp_addr = f"{jmp_addr & ((1 << 15) - 1):015b}"
                if is_immediate(operands[1]):
                    rs2 = int(operands[1], 0)
                    rs2 = f"{rs2 & ((1 << 15) - 1):015b}"
                    machine_code.append(f"00000 00000 {rs1:05b} 10 {rs2}")
                else:
                    rs2 = parse_register(operands[1], line_num)
                    machine_code.append(f"00000 00000 {rs1:05b} 00 0000000000{rs2:05b}")
                machine_code.append(f"{opcode} 00000 00000 10 {jmp_addr}")
                
            # 处理伪指令
            elif op in ['mov', 'inc', 'dec', 'neg', 'clr']:
                if op == 'mov':
                    if len(operands) != 2:
                        raise ValueError(f"第{line_num}行错误：{op} 指令需要两个操作数")
                    rd = parse_register(operands[0], line_num)
                    rs1 = 0
                    if is_immediate(operands[1]):
                        rs2 = int(operands[1], 0)
                        if 0 <= rs2 < 32768:
                            rs2 = f"{rs2 & ((1 << 15) - 1):015b}"
                            machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 10 {rs2}")
                        else:
                            rs2 = format(rs2 & 0xFFFFFFFF, '032b')
                            machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 01 000000000000000")
                            machine_code.append(f"{rs2}")
                    else:
                        rs2 = parse_register(operands[1], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                elif op in ['inc', 'dec']:
                    if len(operands) != 1:
                        raise ValueError(f"第{line_num}行错误：{op} 指令需要一个操作数")
                    rd = parse_register(operands[0], line_num)
                    rs1 = parse_register(operands[0], line_num)
                    machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 10 000000000000001")
                
                elif op == 'neg':
                    if len(operands) != 1:
                        raise ValueError(f"第{line_num}行错误：{op} 指令需要一个操作数")
                    rd = parse_register(operands[0], line_num)
                    rs2 = parse_register(operands[0], line_num)
                    machine_code.append(f"{opcode} {rd:05b} 00000 00 0000000000{rs2:05b}")
                
                elif op == 'clr':
                    if len(operands) != 1:
                        raise ValueError(f"第{line_num}行错误：{op} 指令需要一个操作数")
                    rd = parse_register(operands[0], line_num)
                    machine_code.append(f"{opcode} {rd:05b} 00000 00 000000000000000")
            
            # 处理HDD的sd指令
            elif op == 'sd':
                seek = operands[0]
                data = parse_register(operands[1], line_num)
                if is_immediate(seek):
                    seek = int(operands[0], 0)
                    seek = f"{seek & ((1 << 15) - 1):015b}"
                    machine_code.append(f"{opcode} 00000 {data:05b} 10 {seek}")
                else:
                    machine_code.append(f"{opcode} 00000 {data:05b} 00 0000000000{seek:05b}")
            
            # 处理其他指令
            else:
                if op in ['add', 'sub', 'mul', 'div', 'mod', 'and', 'or', 'xor', 'shl', 'shr'] and len(operands) == 2:
                    operands = [operands[0], operands[0], operands[1]]
                # 有立即数
                if operands and is_immediate(operands[-1]):
                    rs2 = int(operands[-1], 0)
                    # 立即数小于等于15位
                    if 0 <= rs2 < 32768:
                        rs2 = f"{rs2 & ((1 << 15) - 1):015b}"
                        rs2 = "10" + rs2
                    # 立即数大于15位小于32位
                    else:
                        imm = format(rs2 & 0xFFFFFFFF, '032b')
                        rs2 = '01000000000000000'
                    if len(operands) == 1:  # 只有一个操作数
                        rd = 0
                        rs1 = 0
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} {rs2}")
                    elif len(operands) == 2:  # 有两个操作数
                        if op in ['not', 'ld']:
                            rd = parse_register(operands[0], line_num)
                            rs1 = 0
                            machine_code.append(f"{opcode} {rd:05b} {rs1:05b} {rs2}")
                        elif op in ['sw', 'draw']:
                            rd = 0
                            rs1 = parse_register(operands[0], line_num)
                            machine_code.append(f"{opcode} {rd:05b} {rs1:05b} {rs2}")
                    else:  # 有三个操作数
                        rd = parse_register(operands[0], line_num)
                        rs1 = parse_register(operands[1], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} {rs2}")
                    if rs2 == '01000000000000000':
                        machine_code.append(f"{imm}")

                # 无立即数
                else:
                    if op in ['nop', 'ret', 'halt']:
                        if len(operands) != 0:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要零个操作数")
                        rd = 0
                        rs1 = 0
                        rs2 = 0
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['add', 'sub', 'mul', 'div', 'mod', 'and', 'or', 'xor', 'shl', 'shr']:
                        if len(operands) != 3:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要三个操作数")
                        rd = parse_register(operands[0], line_num)
                        rs1 = parse_register(operands[1], line_num)
                        rs2 = parse_register(operands[2], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['not']:
                        if len(operands) != 2:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要两个操作数")
                        rd = parse_register(operands[0], line_num)
                        rs1 = 0
                        rs2 = parse_register(operands[1], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['push', 'console']:
                        if len(operands) != 1:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要一个操作数")
                        rd = 0
                        rs1 = 0
                        rs2 = parse_register(operands[0], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['pop']:
                        if len(operands) != 1:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要一个操作数")
                        rd = parse_register(operands[0], line_num)
                        rs1 = 0
                        rs2 = 0
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['sw', 'draw']:
                        if len(operands) != 2:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要两个操作数")
                        rd = 0
                        rs1 = parse_register(operands[0], line_num)
                        rs2 = parse_register(operands[1], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['lw']:
                        if len(operands) != 2:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要两个操作数")
                        rd = parse_register(operands[0], line_num)
                        rs1 = parse_register(operands[1], line_num)
                        rs2 = 0
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['ld']:
                        if len(operands) != 2:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要两个操作数")
                        rd = parse_register(operands[0], line_num)
                        rs1 = 0
                        rs2 = parse_register(operands[1], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

                    elif op in ['in']:
                        if len(operands) != 2:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要两个操作数")
                        rd = parse_register(operands[0], line_num)
                        rs1 = 0
                        if operands[1] == 'time':
                            rs2 = 0
                        elif operands[1] == 'kbd':
                            rs2 = 1
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 10 0000000000{rs2:05b}")

                    elif op in ['sc']:
                        if len(operands) != 1:
                            raise ValueError(f"第{line_num}行错误：{op} 指令需要一个操作数")
                        rd = 0
                        rs1 = 0
                        rs2 = parse_register(operands[0], line_num)
                        machine_code.append(f"{opcode} {rd:05b} {rs1:05b} 00 0000000000{rs2:05b}")

        else:
            raise ValueError(f"第{line_num}行错误：不支持的操作符 '{op}'")

        # 添加对应的原始汇编注释行
        final_lines.append(assembly_lines[i])
        if operands and is_immediate(operands[-1]):
            imm_val = int(operands[-1], 0)
            if imm_val < 0 or imm_val >= 32768:
                final_lines.append('')
        if op in ['je', 'jne', 'jl', 'jle', 'jg', 'jge']:
            final_lines.append('')

    return machine_code, final_lines



def open_file_dialog():
    """弹出文件选择框"""
    root = tk.Tk()
    root.withdraw()  # 隐藏主窗口
    file_path = filedialog.askopenfilename(title="选择汇编代码文件", filetypes=[("汇编文件", "*.asm"), ("所有文件", "*.*")])
    return file_path


def save_file_dialog():
    """弹出文件保存框"""
    root = tk.Tk()
    root.withdraw()  # 隐藏主窗口
    file_path = filedialog.asksaveasfilename(
        title="保存机器码文件",
        defaultextension=".hex",
        filetypes=[
            ("十六进制机器码文件 (*.hex)", "*.hex"),
            ("二进制机器码文件 (*.bin)", "*.bin"),
            ("所有文件", "*.*")
        ]
    )
    return file_path


def read_assembly_file(file_path):
    """读取汇编文件并返回每行内容"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        return lines
    except FileNotFoundError:
        print(f"错误: 找不到文件 {file_path}")
        return []
    except IOError as e:
        print(f"错误: 无法读取文件 {file_path}，原因: {e}")
        return []
    except UnicodeDecodeError as e:
        print(f"错误: 无法解码文件 {file_path}，请检查文件编码。")
        return []


def write_machine_code(machine_code, final_lines, output_file):
    """将机器码写入文件"""
    is_hex = output_file.endswith('.hex')
    try:
        with open(output_file, 'w', encoding='utf-8') as file:
            for i, (code_line, asm_line) in enumerate(zip(machine_code, final_lines), 1):
                bin_str = code_line.replace(' ', '')  # 去掉空格
                if len(bin_str) != 32:
                    error_details = (
                        f"第 {i} 行机器码位数错误: 应为32位，实际为{len(bin_str)}位\n"
                        f"├─ 汇编行: {asm_line.strip()}\n"
                        f"└─ 生成的机器码: {bin_str}"
                    )
                    raise ValueError(error_details)
                if is_hex:
                    hex_str = f"0x{int(bin_str, 2):08X}"
                    file.write(f"{hex_str}  # {asm_line.strip()}\n")
                else:
                    file.write(f"{bin_str}\n")

        print(f"机器码已保存到：{output_file}")
    except IOError as e:
        print(f"错误: 无法写入文件 {output_file}，原因: {e}")
    except ValueError as ve:
        print(f"机器码转换错误：{ve}")


def main():
    """主程序入口"""
    input_file = open_file_dialog()
    if not input_file:
        print("未选择输入文件。")
        return

    output_file = save_file_dialog()
    if not output_file:
        print("未选择输出文件。")
        return

    lines = read_assembly_file(input_file)
    if not lines:
        return

    print(f"开始汇编: {input_file}")
    print(f"找到 {len(lines)} 行代码")

    assembly_lines, line_map = parse_const_label(lines)
    resolved_lines = replace_const_label(assembly_lines)
    machine_code, final_lines = parse_instruction(resolved_lines, line_map, assembly_lines)

    print(f"生成 {len(machine_code)} 条机器码")

    # 输出机器码到文件
    write_machine_code(machine_code, final_lines, output_file)


if __name__ == "__main__":
    main()
