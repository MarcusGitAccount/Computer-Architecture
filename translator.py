# rough translation of MIPS 16bit assembly code
# into vhdl machine code

# I type instructions
def addi(rt, rs, imm):
  return '_'.join(['001', rs, rt, imm])

def sw(rt, rs, imm):
  return '_'.join(['011', rs, rt, imm])

def lw(rt, rs, imm):
  return '_'.join(['010', rs, rt, imm])

def beq(rs, rt, imm):
  return '_'.join(['100', rs, rt, imm])

def blt(rs, rt, imm):
  return '_'.join(['101', rs, rt, imm])

def bgt(rs, rt, imm):
  return '_'.join(['110', rs, rt, imm])

# R type instructions

def add(rd, rs, rt):
  sa = '0'
  func = '000'
  return '_'.join(['000', rs, rt, rd, sa, func])

def and_(rd, rs, rt):
  sa = '0'
  func = '100'
  return '_'.join(['000', rs, rt, rd, sa, func])

def sra(rd, rs, sa):
  rt = '000'
  func = '110'
  return '_'.join(['000', rs, rt, rd, sa, func])

def bin(n, size):
  # quadratic shit, lol
  res = ''
  for i in range(size):
    res = str(n & 1) + res
    n = n >> 1
  return res


if __name__ == "__main__":
  print(lw(bin(1, 3), bin(0, 3), bin(0, 7)))
  print(lw(bin(7, 3), bin(0, 3), bin(1, 7)))

  print(and_(bin(2, 3), bin(2, 3), bin(0, 3)))
  print(addi(bin(3, 3), bin(1, 3), bin(-1, 7)))

  print(addi(bin(4, 3), bin(0, 3), bin(1, 7)))

  print(add(bin(5, 3), bin(2, 3), bin(3, 3)))
  print(sra(bin(5, 3), bin(5, 3), bin(1, 1)))

  print(add(bin(6, 3), bin(5, 3), bin(4, 3)))
  print(lw(bin(6, 3), bin(6, 3), bin(0, 7)))

  print(beq(bin(2, 3), bin(3, 3), bin(7, 7)))
  print(bgt(bin(2, 3), bin(3, 3), bin(8, 7)))

  print(blt(bin(6, 3), bin(7, 3), bin(1, 7)))
  print(bgt(bin(6, 3), bin(7, 3), bin(2, 7)))

  print(addi(bin(3, 3), bin(5, 3), bin(-1, 7)))
  print(beq(bin(0, 3), bin(0, 3), bin(-10, 7)))

  print(addi(bin(2, 3), bin(5, 3), bin(1, 7)))
  print(beq(bin(0, 3), bin(0, 3), bin(-12, 7)))

  print(add(bin(1, 3), bin(5, 3), bin(0, 3)))
  print(beq(bin(0, 3), bin(0, 3), bin(1, 7)))

  print(addi(bin(1, 3), bin(0, 3), bin(-1, 7)))
