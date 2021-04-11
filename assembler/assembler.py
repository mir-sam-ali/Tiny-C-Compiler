import sys

def placeholders(type, size):
    pass



def process_alus(instruction, variables):
    if instruction[2] == "=":
        res = f"{instruction[0]}\n\tlui $t0, 0x1001\n"
        res += f"\taddi $t0, $t0, {variables[instruction[1]].idx*4}\n"
        res += f"\tsw {instruction[3]}, $t0"

# process instructions and return multi line string (assembly instructions)
def process_instructions(instructions, variables):
    res = ""
    for instruction in instructions:
        instruction = instruction.split(" ")
        if instruction[1] == "if":
            res += process_if_stmt(instruction)
        elif instruction[1] == "goto":
            res += f"{instruction[0]} j {instruction[2]}\n"
        elif instruction[1] == "exit":
            res += f"{instruction[0]} jr $ra\n"
        else:
            res += process_alus(instruction, variables)
    
    return res


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
            for var in enumerate(f):
                var = var.split("\n")
                self.variables[var[0]] = {
                    'register': None,
                    'type': var[1],
                    'size': var[2]
                }
            f.close()

        # clear assembly file
        with open('assembly.asm', 'w') as f:
            f.write('')
            f.close()

    def process_if_stmt(self, instruction):
        res = f"{instruction[0]}\n"

        # store constants in registyers
        if type(instruction[2]) == int:
            res += f"\tlw $t4, {instruction[2]}\n"
            instruction[2] = "$t4"
        
        if type(instruction[4]) == int:
            res += f"\tlw $t5, {instruction[4]}\n"
            instruction[4] = "$t5"


        if instruction[3] == "<":
            res = f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}\n"
            return res
        elif instruction[3] == "<=":
            res = f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}\n"
            res += f"\tbeq {instruction[2]}, {instruction[4]}, {instruction[6]}\n" 
            return res
        elif instruction[3] == ">":
            res = f"\tslt $t6, {instruction[4]}, {instruction[2]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}\n"
            return res
        elif instruction[3] == ">=":
            res = f"\tslt $t6, {instruction[2]}, {instruction[4]}\n"
            res += f"\tbne $t6, $zero, {instruction[6]}\n"
            res += f"\tbeq {instruction[2]}, {instruction[4]}, {instruction[6]}\n" 
            return res
        elif instruction[3] == "==":
            res += f"\tbeq {instruction[2]}, {instruction[4]}, {instruction[6]}\n" 
            return res
        else:
            res += f"\tbne {instruction[2]}, {instruction[4]}, {instruction[6]}\n" 
            return res

    def process_assignments(self, instruction):
        # store constants in registers
        res = f"{instruction[0]}\n"

        instruction[1] = instruction[1].split("[")
        if len(instruction[1]) > 1:
            instruction[1][1] = instruction[1][1][:-1]
        else:
            instruction[1] = instruction[1][0]

        if len(instruction[1]) == 1:
            res += f"\tla $t4, {instruction[1]}\n"
            instruction[1] = "$t4"
        else:
            res += f"\tlw $t4, {instruction[1][1]}\n"
            res += f'\tli $t5, 4\n'
            res += f"\tmul $t4, $t4, $t5"
            res += f"\tla $s4, {instruction[1][0]}\n"
            res += f"\tadd $s4, $s4, $t4\n"
            instruction[1] = "$s4"

        if instruction[1] in self.variables:
            res += f"\tla $s0, {instruction[1]}"
            self.variables[instruction[1]].register = "$s0"
        else:
            res += f"\tla $t0, {instruction[1]}"
        

        instruction[3] = instruction[3].split("[")
        if len(instruction[3]) > 1:
            instruction[3][1] = instruction[3][1][:-1]
        else:
            instruction[3] = instruction[3][0]

        if type(instruction[3]) == int:
            res += f"\tlw $t5, {instruction[3]}\n"
            instruction[3] = "$t5"
        else:
            res += f"\tlw $t4, {instruction[3][1]}\n"
            res += f'\tli $t5, 4\n'
            res += f"\tmul $t4, $t4, $t5"
            res += f"\tla $t5, {instruction[3][0]}\n"
            res += f"\tadd $t5, $t5, $t4\n"
            instruction[3] = "$t5"

        if len(instruction[2:]) > 1:
            instruction[5] = instruction[5].split("[")
            if len(instruction[5]) > 1:
                instruction[5][1] = instruction[5][1][:-1]
            else:
                instruction[5] = instruction[5][0]

            if type(instruction[5]) == int:
                res += f"\tlw $t6, {instruction[5]}\n"
                instruction[5] = "$t6"
            else:
                res += f"\tlw $t6, {instruction[5][1]}\n"
                res += f'\tli $t7, 4\n'
                res += f"\tmul $t7, $t7, $t6"
                res += f"\tla $t6, {instruction[5][0]}\n"
                res += f"\tadd $t6, $t6, $t7\n"
                instruction[5] = "$t6"

            if instruction[1] == '+':
                res += f"\tadd $t6, {instruction[3]}, {instruction[5]}\n"

            elif instruction[1] == '-':
                res += f"\tsub $t6, {instruction[3]}, {instruction[5]}\n"
        
            res += f"\tsw $t6, 0({instruction[1]})"
        else:
            res += f"\tsw {instruction[3]}, 0({instruction[1]})"
        
        return res


    def process_instructions(self):
        # converting
        with open('assembly.asm', "a") as f:
            # hard code data part for now
            f.write(".data\n")
            f.write("i: .word 0\n")
            f.write("arr: .word 0 0 0 0 0\n")
            f.write("j: .word 0\n")
            f.write("k: .word 0\n")
            f.write("temp: .word 0\n")
            f.write("\n")

            # text part
            f.write(".text\n")
            f.write("main:\n")

            # f.write(process_instructions(temp, variables))
        
            f.close()


if __name__ == "__main__":
    Assembler()