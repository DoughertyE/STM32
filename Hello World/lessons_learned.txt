compiling code:

//Create object file
arm-none-eabi-gcc -x assembler-with-cpp -c -O0 -mcpu=cortex-m4 -mthumb -Wall core.S -o core.o

//Combine object files (right now only one) and linker into final program
arm-none-eabi-gcc core.o -mcpu=cortex-m4 -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T./linker.ld -o main.elf

//see rough outline of what is in the ELF binary by running "arm-none-eabi-nm main.elf"
	20020000 A _estack
	20000010 t main_loop
	20000008 T reset_handler
	20000000 T vtable



//So, I noticed above that my vtable was not at 0x08000000 like it should be (it should be at the very beginning of program memory). The below linker file was made with the help of ChatGPT. By defnining sections and there locations (ram vs flash), I was able to fix the problem.

/* Highest address of the user mode stack */
_estack = 0x20020000;    /* End of RAM */

/* Define memory regions */
MEMORY
{
  RAM (xrw)   : ORIGIN = 0x20000000, LENGTH = 128K  /* 128 KB RAM */
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 512K  /* 512 KB Flash */
}

/* Define the sections */
SECTIONS
{
  /* The vector table (interrupt vectors) is placed at the start of flash */
  .isr_vector :
  {
    KEEP(*(.isr_vector))  /* Keep the interrupt vector table */
  } > FLASH

  /* The .text section holds code (functions) and read-only data */
  .text :
  {
    *(.text*)    /* All code (functions) */
    *(.rodata*)  /* Read-only data (const variables) */
  } > FLASH

  /* The .data section holds initialized data that is copied to RAM */
  .data : 
  {
    *(.data*)  /* Initialized data */
  } > RAM AT > FLASH  /* Data is loaded from flash but executed from RAM */

  /* The .bss section holds uninitialized data, placed in RAM */
  .bss (NOLOAD) :
  {
    *(.bss*)
  } > RAM

  /* Define the end of the stack (top of RAM) */
  _estack = ORIGIN(RAM) + LENGTH(RAM);

  /* End of memory layout */
  _end = .;
}




// New output showing correct placement of the vtable
0800001c T _end
20020000 T _estack
08000010 t main_loop
08000008 T reset_handler
08000000 T vtable



// I am using WSL2.0 which does not allow USB passthrough. ST-LINK, the software I am using to send code to the STM32, cannot see the device. I must use usbipd-win to get things to work.
	winget install --interactive --exact dorssel.usbipd-win


// Still not working. LD1 is bliking RED at about 1HZ. 
// Fixed. USB cable was either power only or defective.


//Working!
0x08000012 in reset_handler ()
(gdb) info registers
r0             0x16a88ef           23759087
r1             0x0                 0
r2             0x0                 0
r3             0x0                 0
r4             0x0                 0
r5             0x0                 0
r6             0x0                 0
r7             0xdeadbeef          -559038737
