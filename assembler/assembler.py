import sys

def assembler(file):
    # reading ICG file
    temp = []
    with open(file, "r") as f :
        for line in f:
            temp.append(line)
    # print(temp)    
    f.close()

    # reading variable list
    variables = {}
    with open('variables', "r") as f:
        for idx, var in enumerate(f):
            variables[var.split("\n")[0]] = idx
    f.close()
    # print( len(variables))

    # converting
    with open('assemble.asm', "a") as f:
        f.write(".data\n")
        f.write("memory\n")

        zeros = ""
        for _ in range(len(variables) - 1):
            zeros += "0 "
        zeros += "0"
        f.write(f"\t.word {zeros}")
    
    f.close()

if __name__ == "__main__":
    assembler(sys.argv[1])