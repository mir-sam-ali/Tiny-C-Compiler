import sys
import re

class Assembler:
    def __init__(self, ICG_file, variable_file='ICG.vars'):
        # reading ICG file
        self.temp = []
        with open(ICG_file, "r") as f :
            for line in f:
                self.temp.append(line)
            # print(temp)    
            f.close()

        # reading variable list
        self.variables = {}
        with open(variable_file, "r") as f:
            for var in f:
                var = var.split(" ")
                self.variables[var[0]] = {
                    'register': None,
                    'type': var[1],
                    'size': int(var[2].replace('\n', ''))
                }
            f.close()

        # clear assembly file
        with open('output.asm', 'w') as f:
            f.write('')
            f.close()
        
        # data part
        self.data_part = ""
        # text part
        self.text_part = ""
        # print strings
        self.print_stmts = {}
        self.nb_print_stmts = 0

    def write_to_data(self):
        # writing print strings to data
        for k, v in self.print_stmts.items():
            self.data_part += f"{v}: .asciiz {k}\n"

    def placeholders(self):
        res = ".data\n"
        for k, v in self.variables.items():
            v['size'] = v['size']//4
            if v['type'] == '279':
                res += f"{k}: .word {'0 '*(v['size']-1)}0\n"
        self.data_part = res

    def process_if_stmt(self, instruction):
        res = f"L{instruction[0]}\n"

        instruction[2] = instruction[2].split("[")
        if len(instruction[2]) == 1:
            instruction[2] = instruction[2][0]
            if instruction[2][-1] == "\n":
                instruction[2] = instruction[2][:-1]
        else:
            instruction[2][1] = instruction[2][1][:-1]

        try:
            instruction[2] = int(instruction[2])
            res += f"\tli $t5, {instruction[2]}\n"
            instruction[2] = "$t5"
        except:
            if type(instruction[2]) != list and instruction[2] in self.variables.keys():
                res += f"\tla $t5, {instruction[2]}\n"
                res += f"\tlw $t5, 0($t5)\n"
                instruction[2] = "$t5"
            elif type(instruction[2]) == list:
                try:
                    instruction[2][1] = int(instruction[2][1])
                    res += f"\tli $t4, {instruction[2][1]}\n"
                except:
                    res += f"\tla $t4, {instruction[2][1]}\n"
                    res += f"\tlw $t4, 0($t4)\n"
                
                res += f'\tli $t5, 4\n'
                res += f"\tmul $t4, $t4, $t5\n"
                res += f"\tla $t5, {instruction[2][0]}\n"
                res += f"\tadd $t5, $t5, $t4\n"
                res += f"\tlw $t5, 0($t5)\n"
                instruction[2] = "$t5"
            else:
                instruction[2] = f"${instruction[2]}"

        instruction[4] = instruction[4].split("[")
        if len(instruction[4]) == 1:
            instruction[4] = instruction[4][0]
            if instruction[4][-1] == "\n":
                instruction[4] = instruction[4][:-1]
        else:
            instruction[4][1] = instruction[4][1][:-1]

        try:
            instruction[4] = int(instruction[4])
            res += f"\tli $t6, {instruction[4]}\n"
            instruction[4] = "$t6"
        except:
            if type(instruction[4]) != list and instruction[4] in self.variables.keys():
                res += f"\tla $t6, {instruction[4]}\n"
                res += f"\tlw $t6, 0($t6)\n"
                instruction[4] = "$t6"
            elif type(instruction[4]) == list:
                try:
                    instruction[4][1] = int(instruction[4][1])
                    res += f"\tli $t6, {instruction[4][1]}\n"
                except:
                    res += f"\tla $t6, {instruction[4][1]}\n"
                    res += f"\tlw $t6, 0($t6)\n"
                
                res += f'\tli $t4, 4\n'
                res += f"\tmul $t4, $t4, $t6\n"
                res += f"\tla $t6, {instruction[4][0]}\n"
                res += f"\tadd $t6, $t6, $t4\n"
                res += f"\tlw $t6, 0($t6)\n"
                instruction[4] = "$t6"
            else:
                instruction[4] = f"${instruction[4]}"

        if instruction[3] == "<":
            res += f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, L{instruction[6]}"
        elif instruction[3] == "<=":
            res += f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, L{instruction[6]}\n"
            res += f"\tbeq {instruction[2]}, {instruction[4]}, L{instruction[6]}" 
        elif instruction[3] == ">":
            res += f"\tslt $t6, {instruction[4]}, {instruction[2]}\n"
            res += f"\tbne $t6, $zero, L{instruction[6]}"
        elif instruction[3] == ">=":
            res += f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, L{instruction[6]}\n"
            res += f"\tbeq {instruction[2]}, {instruction[4]}, L{instruction[6]}" 
        elif instruction[3] == "==":
            res += f"\tbeq {instruction[2]}, {instruction[4]}, L{instruction[6]}" 
        else:
            res += f"\tbne {instruction[2]}, {instruction[4]}, L{instruction[6]}" 
        return res

    def process_assignments(self, instruction):
        # store constants in registers
        res = f"L{instruction[0]}\n"
        is_temp = False

        # array assignment or normal assignment
        instruction[1] = instruction[1].split("[")
        if len(instruction[1]) > 1:
            instruction[1][1] = instruction[1][1][:-1]
        else:
            instruction[1] = instruction[1][0]

        if type(instruction[1]) != list and instruction[1] in self.variables.keys():
            res += f"\tla $s4, {instruction[1]}\n"
            instruction[1] = "$s4"
        else:
            if instruction[1][0] in self.variables.keys():
                try:
                    instruction[1][1] = int(instruction[1][1])
                    res += f"\tli $t4, {instruction[1][1]}\n"
                except:
                    res += f"\tla $t4, {instruction[1][1]}\n"
                    res += f"\tlw $t4, 0($t4)\n"
            
                res += f'\tli $t5, 4\n'
                res += f"\tmul $t4, $t4, $t5\n"
                res += f"\tla $s4, {instruction[1][0]}\n"
                res += f"\tadd $s4, $s4, $t4\n"
                instruction[1] = "$s4"
            else:
                is_temp = True
                instruction[1] = f"${instruction[1]}"

        instruction[3] = instruction[3].split("[")
        if len(instruction[3]) == 1:
            instruction[3] = instruction[3][0]
            if instruction[3][-1] == "\n":
                instruction[3] = instruction[3][:-1]
        else:
            instruction[3][1] = instruction[3][1][:-1]

        try:
            instruction[3] = int(instruction[3])
            res += f"\tli $t5, {instruction[3]}\n"
            instruction[3] = "$t5"
        except:
            if type(instruction[3]) != list and instruction[3] in self.variables.keys():
                res += f"\tla $t5, {instruction[3]}\n"
                res += f"\tlw $t5, 0($t5)\n"
                instruction[3] = "$t5"
            elif type(instruction[3]) == list:
                try:
                    instruction[3][1] = int(instruction[3][1])
                    res += f"\tli $t4, {instruction[3][1]}\n"
                except:
                    res += f"\tla $t4, {instruction[3][1][:-1]}\n"
                    res += f"\tlw $t4, 0($t4)\n"
                
                res += f'\tli $t5, 4\n'
                res += f"\tmul $t4, $t4, $t5\n"
                res += f"\tla $t5, {instruction[3][0]}\n"
                res += f"\tadd $t5, $t5, $t4\n"
                res += f"\tlw $t5, 0($t5)\n"
                instruction[3] = "$t5"
            else:
                instruction[3] = f"${instruction[3]}"

        if len(instruction) > 4:
            # print(instruction)
            instruction[5] = instruction[5][:-1]
            instruction[5] = instruction[5].split("[")
            if len(instruction[5]) > 1:
                instruction[5][1] = instruction[5][1][:-1]
            else:
                instruction[5] = instruction[5][0]

            try:
                instruction[5] = int(instruction[5])
                res += f"\tli $t6, {instruction[5]}\n"
                instruction[5] = "$t6"
            except:
                if type(instruction[5]) != list and instruction[5] in self.variables.keys():
                    res += f"\tla $t6, {instruction[5]}\n"
                    res += f"\tlw $t6, 0($t6)\n"
                    instruction[5] = "$t6"
                elif type(instruction[5]) == list:
                    try:
                        instruction[5][1] = int(instruction[5][1])
                        res += f"\tli $t4, {instruction[5][1]}\n"
                    except:
                        res += f"\tla $t4, {instruction[5][1][:-1]}\n"
                        res += f"\tlw $t4, 0($t4)\n"

                    res += f'\tli $t7, 4\n'
                    res += f"\tmul $t7, $t7, $t6\n"
                    res += f"\tla $t6, {instruction[5][0]}\n"
                    res += f"\tadd $t6, $t6, $t7\n"
                    res += f"\tlw $t6, 0($t6)\n"
                    instruction[5] = "$t6"
                else:
                    instruction[5] = f"${instruction[5]}"

            if instruction[4] == '+':
                res += f"\tadd $t6, {instruction[3]}, {instruction[5]}\n"

            elif instruction[4] == '-':
                res += f"\tsub $t6, {instruction[3]}, {instruction[5]}\n"
        
            if is_temp:
                res += f"\taddi {instruction[1]}, $t6, 0\n"
            else:
                res += f"\tsw $t6, 0({instruction[1]})\n"
        else:
            if is_temp:
                res += f"\taddi {instruction[1]}, {instruction[3]}, 0\n"
            else:
                res += f"\tsw {instruction[3]}, 0({instruction[1]})\n"
        
        return res

    def process_print_stmt(self, instruction):
        # split correctly
        stmts = re.findall(r'\".*?\"', instruction)
        for stmt in stmts:
            if stmt not in self.print_stmts.keys():
                self.print_stmts[stmt] = f"prompt{self.nb_print_stmts}"
                self.nb_print_stmts += 1
            instruction = instruction.replace(stmt, self.print_stmts[stmt])

        instruction = instruction.split(" ")
        res = f"L{instruction[0]}\n"
        
        for i in range(2, len(instruction)):
            
            instruction[i] = instruction[i].replace("\n", "")

            if instruction[i] in list(self.print_stmts.values()):
                res += "\tli $v0, 4\n"
                res += f"\tla $a0, {instruction[i]}\n"
            else:
                res += "\tli $v0, 1\n"
                instruction[i] = instruction[i].split("[")
                if len(instruction[i]) == 1:
                    instruction[i] = instruction[i][0]
                    if instruction[i][-1] == "\n":
                        instruction[i] = instruction[i][:-1]
                else:
                    instruction[i][1] = instruction[i][1][:-1]

                if type(instruction[i]) != list and instruction[i] in self.variables.keys():
                    res += f"\tla $a0, {instruction[i]}\n"
                elif type(instruction[i]) == list:
                    try:
                        instruction[i][1] = int(instruction[i][1])
                        res += f"\tli $t4, {instruction[i][1]}\n"
                    except:
                        res += f"\tla $t4, {instruction[i][1]}\n"
                        res += f"\tlw $t4, 0($t4)\n"
                        
                    res += f'\tli $t5, 4\n'
                    res += f"\tmul $t4, $t4, $t5\n"
                    res += f"\tla $t5, {instruction[i][0]}\n"
                    res += f"\tadd $t5, $t5, $t4\n"
                    res += f"\tlw $t5, 0($t5)\n"
                    res += f"\tmove $a0, $t5\n"
            
            res += "\tsyscall\n"
        return res

    def assemble(self):
        res = ""
        for line in self.temp:
            instruction = line.split(" ")
            if instruction[1] == "if":
                res += self.process_if_stmt(instruction)
            elif instruction[1] == "goto":
                res += f"L{instruction[0]} j L{instruction[2]}"
            elif instruction[1] == "exit" or instruction[1] == "exit\n":
                res += f"L{instruction[0]} jr $ra"
            elif instruction[1] == "print":
                res += self.process_print_stmt(" ".join(instruction))
            else:
                res += self.process_assignments(instruction)

        self.text_part = res


    def process_instructions(self):
        # converting
        self.placeholders()
        self.assemble()
        self.write_to_data()

        with open('output.asm', "a") as f:
            # data part
            f.write(self.data_part)
            # text part
            f.write("\n.text\n")
            f.write("main:\n")
            f.write(self.text_part)
        
            f.close()


if __name__ == "__main__":
    Assembler(sys.argv[1]).process_instructions()