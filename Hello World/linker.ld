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
