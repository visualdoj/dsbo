# Small Buffer Optimizations for Free Pascal

## Overview

Small buffer optimization is supposed to be used in a code that requires to
allocate memory for data of arbitrary size, but the data is small in most
cases. It is more effecient to try to use small buffer first (placed on stack,
global memory or allocated in heap somewhere out of scope of the code) so it
prevents actual allocation, and only if the buffer is smaller than required
amount of memory, actually allocate buffer on heap.

The library makes the optimization as easy as GetMem/FreeMem.

It provides two units. Both do the same thing semantically, but interfaces
differ: [dsbo.pas](dsbo.pas) provides procedural interface and
[dsmallbufferoptimization.pas](dsmallbufferoptimization.pas) provides OOP
interface. Which one to use is up to you.

## dsbo (procedural version)

The unit provides `SBOGetMem`, `SBOFreeMem` and `SBOReAllocMem` functions. They
behave the same way as respecitve functions from the FPC RTL System unit, but
require extra parameter to be passed (the "small buffer").

Representative example:

```pascal
uses
  dsbo;

  procedure DoSomething(N: SizeUInt);
  var
    // Local buffer placed on the stack for up to 64 bytes
    LocalBuf: array[0 .. 64 - 1] of Byte;
    // Pointer to actual data
    Data: Pointer;
  begin
    // Allocate N bytes
    //   if N <= Length(LocalBuf), it effectively returns @LocalBuf[0]
    //   if N >  Length(LocalBuf), it uses GetMem to allocate memory on heap
    Data := SBOGetMem(LocalBuf, N);
    // Use Data as usual
    //...
    // Don't forget to free the memory
    SBOFreeMem(LocalBuf, Data);
  end;
```

## dsmallbufferoptimization (OOP version)

This unit provides `TSmallBufferHolder` object that is RAII for allocated
memory. It must be initialized with `Init` method (constructor) and finalized
with `Done` method (destructor). Method `Data` returns pointer to actual data.

Above example can be rewritten with the `dsmallbufferoptimization` unit:

```pascal
uses
  dsmallbufferoptimization;

  procedure DoSomething(N: SizeUInt);
  var
    // Local buffer placed on stack for up to 64 bytes
    LocalBuf: array[0 .. 64 - 1] of Byte;
    // Pointer to actual data
    SmallBufferHolder: TSmallBufferHolder;
  begin
    // Initialize the holder and allocate memory
    SmallBufferHolder.Init(LocalBuf, N);
    // Use SmallBufferHolder.Data as usual pointer
    // ...
    // Don't forget to finalize the object
    SmallBufferHolder.Done;
  end;
```
