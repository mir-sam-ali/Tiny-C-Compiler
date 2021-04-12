import sys

class Assembler:
    def __init__(self, ICG_file, variable_file='variables'):
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

    def placeholders(self):
        res = ""
        for k, v in self.variables.items():
            if v['type'] == 'int':
                res += f"{k}: .word {'0 '*(v['size']-1)}0\n"
        return res

    def process_if_stmt(self, instruction):
        res = f"{instruction[0]}\n"

        # store constants in registyers
        try:
            instruction[2] = int(instruction[2])
            res += f"\tlw $t4, {instruction[2]}\n"
            instruction[2] = "$t4"
        except:
            if instruction[2] in self.variables.keys():
                res += f"\tla $t4, {instruction[2]}\n"
                res += f"\tlw $t4, 0($t4)\n"
                instruction[2] = "$t4"
            else:
                instruction[2] = f"${instruction[2]}"

        try:
            instruction[4] = int(instruction[4])
            res += f"\tlw $t5, {instruction[4]}\n"
            instruction[4] = "$t5"
        except:
            if instruction[4] in self.variables.keys():
                res += f"\tla $t5, {instruction[4]}\n"
                res += f"\tlw $t5, 0($t5)\n"
                instruction[4] = "$t5"
            else:
                instruction[4] = f"${instruction[4]}"

        if instruction[3] == "<":
            res += f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}"
        elif instruction[3] == "<=":
            res += f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}\n"
            res += f"\tbeq {instruction[2]}, {instruction[4]}, {instruction[6]}" 
        elif instruction[3] == ">":
            res += f"\tslt $t6, {instruction[4]}, {instruction[2]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}"
        elif instruction[3] == ">=":
            res += f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}\n"
            res += f"\tbeq {instruction[2]}, {instruction[4]}, {instruction[6]}" 
        elif instruction[3] == "==":
            res += f"\tbeq {instruction[2]}, {instruction[4]}, {instruction[6]}" 
        else:
            res += f"\tbne {instruction[2]}, {instruction[4]}, {instruction[6]}" 
        return res

    def process_assignments(self, instruction):
        # store constants in registers
        res = f"{instruction[0]}\n"

        # array assignment or normal assignment
        instruction[1] = instruction[1].split("[")
        if len(instruction[1]) > 1:
            instruction[1][1] = instruction[1][1][:-1]
        else:
            instruction[1] = instruction[1][0]

        if len(instruction[1]) == 1:
            res += f"\tla $t4, {instruction[1]}\n"
            instruction[1] = "$t4"
        else:
            if instruction[1][1] in self.variables.keys():
                res += f"\tlw $t4, {instruction[1][1]}\n"
                res += f'\tli $t5, 4\n'
                res += f"\tmul $t4, $t4, $t5\n"
                res += f"\tla $s4, {instruction[1][0]}\n"
                res += f"\tadd $s4, $s4, $t4\n"
                instruction[1] = "$s4"
            else:
                instruction[1] = f"${instruction[1]}"

        instruction[3] = instruction[3].split("[")
        if len(instruction[3]) == 1:
            instruction[3] = instruction[3][0]
        else:
            instruction[3][1] = instruction[3][1][:-1]

        try:
            instruction[3] = int(instruction[3])
            res += f"\tlw $t5, {instruction[3]}\n"
            instruction[3] = "$t5"
        except:
            if type(instruction[3]) != list and instruction[3] in self.variables.keys():
                res += f"\tla $t5, {instruction[3]}\n"
                res += f"\tlw $t5, 0($t5)\n"
                instruction[3] = "$t5"
            elif type(instruction[3]) == list:
                res += f"\tlw $t4, {instruction[3][1]}\n"
                res += f'\tli $t5, 4\n'
                res += f"\tmul $t4, $t4, $t5\n"
                res += f"\tla $t5, {instruction[3][0]}\n"
                res += f"\tadd $t5, $t5, $t4\n"
                res += f"\tlw $t5, 0($t5)\n"
                instruction[3] = "$t5"
            else:
                instruction[3] = f"${instruction[3][:-1]}"

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
                res += f"\tlw $t6, {instruction[5]}\n"
                instruction[5] = "$t6"
            except:
                if type(instruction[5]) != list and instruction[5] in self.variables.keys():
                    res += f"\tla $t6, {instruction[5]}\n"
                    res += f"\tlw $t6, 0($t6)\n"
                    instruction[5] = "$t6"
                elif type(instruction[5]) == list:
                    res += f"\tlw $t6, {instruction[5][1]}\n"
                    res += f'\tli $t7, 4\n'
                    res += f"\tmul $t7, $t7, $t6\n"
                    res += f"\tla $t6, {instruction[5][0]}\n"
                    res += f"\tadd $t6, $t6, $t7\n"
                    res += f"\tlw $t6, 0($t6)\n"
                    instruction[5] = "$t6"
                else:
                    instruction[5] = f"${instruction[5][:-1]}"

            if instruction[4] == '+':
                res += f"\tadd $t6, {instruction[3]}, {instruction[5]}\n"

            elif instruction[4] == '-':
                res += f"\tsub $t6, {instruction[3]}, {instruction[5]}\n"
        
            if instruction[1] in ["$t0", "$t1", "$t2"]:
                res += f"\taddi {instruction[1]}, $t6, 0\n"
            else:
                res += f"\tsw $t6, 0({instruction[1]})\n"
        else:
            if instruction[1] in ["$t0", "$t1", "$t2"]:
                res += f"\taddi {instruction[1]}, {instruction[3]}, 0\n"
            else:
                res += f"\tsw {instruction[3]}, 0({instruction[1]})\n"
        
        return res


    def process_instructions(self):
        # converting
        with open('output.asm', "a") as f:
            # data part
            f.write(".data\n")
            f.write(self.placeholders())

            # text part
            f.write("\n.text\n")
            f.write("main:\n")
            # f.write(self.assemble())
        
            f.close()


if __name__ == "__main__":
    Assembler(sys.argv[1]).process_instructions()