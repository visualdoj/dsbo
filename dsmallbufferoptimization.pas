//
//  dsmallbufferoptimization - simple library for small buffer optimizations
//
{$MODE FPC}
{$MODESWITCH DEFAULTPARAMETERS}
{$MODESWITCH RESULT}
unit dsmallbufferoptimization;

interface

type
TSmallBufferHolder = object
private
  // Pointer to actual data: either FBuf or allocated memory
  FData: Pointer;
  // The object stores pointer to small buffer
  FBuf: Pointer;
  FBufLen: SizeUInt;
public
  // Initializes the object and allocates Size bytes either in small buffer
  // or in the heap
  procedure Init(var Buf: array of Byte;
                 Size: SizeUInt = 0);
  procedure Init(Buf: Pointer; BufLen: SizeUInt;
                 Size: SizeUInt = 0);
  // Frees allocated memory if needed
  procedure Done; inline;
  // Reallocates memory
  procedure ReAllocate(NewSize: SizeUInt);
  // Checks whenever Data is in heap
  function InHeap: Boolean; inline;
  // Returns pointer to the memory
  function Data: Pointer; inline;
end;

implementation

procedure TSmallBufferHolder.Init(var Buf: array of Byte;
                            Size: SizeUInt = 0);
begin
  Init(@Buf[0], Length(Buf), Size);
end;

procedure TSmallBufferHolder.Init(Buf: Pointer; BufLen: SizeUInt;
                            Size: SizeUInt = 0);
begin
  FBuf := Buf;
  FBufLen := BufLen;
  if Size <= FBufLen then begin
    FData := FBuf;
  end else begin
    GetMem(FData, Size);
  end;
end;

procedure TSmallBufferHolder.Done;
begin
  if FData <> FBuf then
    FreeMem(FData);
end;

procedure TSmallBufferHolder.ReAllocate(NewSize: SizeUInt);
begin
  if NewSize <= FBufLen then
    Exit;
  if FData <> FBuf then begin
    FData := ReAllocMem(FData, NewSize);
  end else begin
    GetMem(FData, NewSize);
    Move(FBuf^, FData^, FBufLen);
  end;
end;

function TSmallBufferHolder.InHeap: Boolean;
begin
  Result := FData <> FBuf;
end;

function TSmallBufferHolder.Data: Pointer;
begin
  Result := FData;
end;

end.
