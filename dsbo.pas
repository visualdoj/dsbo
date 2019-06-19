//
//  dsbo - Doj's small buffer optimization
//
//  Example:
//
//      procedure DoSomething(N: SizeUInt);
//      var
//        // Local buffer for 64 bytes
//        _LocalBuffer: array[0 .. 64 - 1] of Byte;
//        // Pointer to actual buffer
//        Data: Pointer;
//      begin
//        // Allocate memory
//        Data := SBOGetMem(_LocalBuffer, N);
//        // Now we can use Data...
//        ...
//        // Free the memory
//        SBOFreeMem(_LocalBuffer, Data);
//      end;
//
{$MODE FPC}
{$MODESWITCH RESULT}
unit dsbo;

interface

//
//  SBOGetMem
//
//      Allocates Size bytes. It tries to use the Buf as allocated memory.
//      If size of the buffer is smaller than Size, than memory will be
//      allocated on heap.
//
//      Returned memory from the function should be deallocated with SBOFreeMem.
//
//  Parameters:
//
//      Buf: the buffer
//      BufLen: length of the buffer
//      Size: number of bytes to be allocated
//
//  Returns:
//
//      Result: allocated memory.
//
function SBOGetMem(var Buf: array of Byte; Size: SizeUInt): Pointer; inline;
function SBOGetMem(Buf: Pointer; BufLen: SizeUInt; Size: SizeUInt): Pointer; inline;

//
//  SBOFreeMem
//
//      Frees memory allocated with SBOGetMem. Passed Buf should be the
//      same as passed to the SBOGetMem.
//
//  Parameters:
//
//      Buf: the buffer
//      BufLen: length of the buffer
//      Data: pointer returned by SBOGetMem
//
procedure SBOFreeMem(var Buf: array of Byte; Data: Pointer); inline;
procedure SBOFreeMem(Buf: Pointer; BufLen: SizeUInt; Data: Pointer); inline;

//
//  SBOReAllocMem
//
//      Reallocates memory allocated with SBOGetMem. The contents of the memory
//      pointed to by the Data will be copied to new location.
//
//  Parameters:
//
//      Buf: the buffer
//      BufLen: length of the buffer
//      Data: pointer returned by SBOGetMem
//      Size: new size
//
//  Returns:
//
//      Result: pointer to new memory location
//
function SBOReAllocMem(var Buf: array of Byte; Data: Pointer; Size: SizeUInt): Pointer; inline;
function SBOReAllocMem(Buf: Pointer; BufLen: SizeUInt; Data: Pointer; Size: SizeUInt): Pointer;

implementation

function SBOGetMem(var Buf: array of Byte; Size: SizeUInt): Pointer;
begin
  if Size < Length(Buf) then begin
    Result := @Buf[0];
  end else
    GetMem(Result, Size);
end;

function SBOGetMem(Buf: Pointer; BufLen: SizeUInt; Size: SizeUInt): Pointer;
begin
  if Size < BufLen then begin
    Result := Buf;
  end else
    GetMem(Result, Size);
end;

procedure SBOFreeMem(var Buf: array of Byte; Data: Pointer);
begin
  if Data <> @Buf[0] then
    FreeMem(Data);
end;

procedure SBOFreeMem(Buf: Pointer; BufLen: SizeUInt; Data: Pointer);
begin
  if Data <> Buf then
    FreeMem(Data);
end;

function SBOReAllocMem(var Buf: array of Byte; Data: Pointer; Size: SizeUInt): Pointer;
begin
  Result := SBOReAllocMem(@Buf[0], Length(Buf), Data, Size);
end;

function SBOReAllocMem(Buf: Pointer; BufLen: SizeUInt; Data: Pointer; Size: SizeUInt): Pointer;
begin
  if Size <= BufLen then
    Exit(Data);
  if Data = Buf then begin
    GetMem(Result, Size);
    // We don't know old size, so copy all data from the small buffer
    Move(Buf^, Result^, BufLen);
  end else begin
    Result := ReAllocMem(Data, Size);
  end;
end;

end.
