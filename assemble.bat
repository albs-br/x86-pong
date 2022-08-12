@echo off
REM SIMPLE COMMAND.COM SCRIPT TO ASSEMBLE x86 FILES

REM if exist obj\%2.gb del obj\%2.gb

:begin
set assemble=1
set nasm_path=C:\Users\albs_\OneDrive\Desktop\Assembly x86\nasm-2.15.05-win64\nasm-2.15.05\

echo assembling...
"%nasm_path%nasm.exe" -f bin %1.asm -o %2.com

:end