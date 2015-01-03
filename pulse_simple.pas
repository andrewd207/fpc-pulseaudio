{***
  This file is part of PulseAudio.

  Copyright 2004-2006 Lennart Poettering
  Copyright 2006 Pierre Ossman <ossman@cendio.se> for Cendio AB

  PulseAudio is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as published
  by the Free Software Foundation; either version 2.1 of the License,
  or (at your option) any later version.

  PulseAudio is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with PulseAudio; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA.
***}
unit pulse_simple;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}
{$linklib pulse-simple}

interface

uses
  Classes, SysUtils, pulse_sample, pulse_channelmap, pulse_def, pulse_version, ctypes;

type
  PPASimple = ^TPASimple;

  { TPASimple }

  TPASimple = object sealed
    function New(
      server: PChar;           {**< Server name, or NULL for default *}
      name: PChar;             {**< A descriptive name for this client (application name, ...) *}
      dir: TPAStreamDirection; {**< Open this stream for recording or playback? *}
      dev: PChar;              {**< Sink (resp. source) name, or NULL for default *}
      stream_name: PChar;      {**< A descriptive name for this stream (application name, song title, ...) *}
      ss: PPASampleSpec;       {**< The sample type to use *}
      map: PPAChannelMap;      {**< The channel map to use, or NULL for default *}
      attr: PPABufferAttr;     {**< Buffering attributes, or NULL for default *}
      error: pcint             {**< A pointer where the error code is stored when the routine returns NULL. It is OK to pass NULL here. *}
      ): PPASimple; static;
    procedure Free;
    function Write(data: Pointer; bytes: csize_t; error: pcint = nil): cint;
    function Drain(error: pcint): cint;
    function Read(data: Pointer; bytes: csize_t; error: pcint = nil): cint;
    function GetLatency(error: pcint = nil): QWord;
    function Flush(error: pcint = nil): cint;
  end;

{** Create a new connection to the server. *}
function pa_simple_new(
      server: PChar;           {**< Server name, or NULL for default *}
      name: PChar;             {**< A descriptive name for this client (application name, ...) *}
      dir: TPAStreamDirection; {**< Open this stream for recording or playback? *}
      dev: PChar;              {**< Sink (resp. source) name, or NULL for default *}
      stream_name: PChar;      {**< A descriptive name for this stream (application name, song title, ...) *}
      ss: PPASampleSpec;       {**< The sample type to use *}
      map: PPAChannelMap;      {**< The channel map to use, or NULL for default *}
      attr: PPABufferAttr;     {**< Buffering attributes, or NULL for default *}
      error: pcint             {**< A pointer where the error code is stored when the routine returns NULL. It is OK to pass NULL here. *}
      ): PPASimple external;

{** Close and free the connection to the server. The connection object becomes invalid when this is called. *}
procedure pa_simple_free(s: PPASimple) external;

{** Write some data to the server. *}
function pa_simple_write(s: PPASimple; data: pointer; bytes: csize_t; error: pcint): cint external;

{** Wait until all data already written is played by the daemon. *}
function pa_simple_drain(s: PPASimple; error: pcint): cint external;

{** Read some data from the server. This function blocks until \a bytes amount
 * of data has been received from the server, or until an error occurs.
 * Returns a negative value on failure. *}
function pa_simple_read(
    s: PPASimple;   {**< The connection object. *}
    data: Pointer;  {**< A pointer to a buffer. *}
    bytes: csize_t; {**< The number of bytes to read. *}
    error: pcint    {**< A pointer where the error code is stored when the function returns
                       * a negative value. It is OK to pass NULL here. *}
    ): cint external;

{** Return the playback or record latency. *}
function pa_simple_get_latency(s: PPASimple; error: pcint): QWord external;

{** Flush the playback or record buffer. This discards any audio in the buffer. *}
function pa_simple_flush(s : PPASimple; error: pcint): cint external;

implementation

{ TPASimple }

function TPASimple.New(server: PChar; name: PChar; dir: TPAStreamDirection;
  dev: PChar; stream_name: PChar; ss: PPASampleSpec; map: PPAChannelMap;
  attr: PPABufferAttr; error: pcint): PPASimple;
begin
  Result := pa_simple_new(server, name, dir,dev,stream_name,ss,map,attr,error);
end;

procedure TPASimple.Free;
begin
 pa_simple_free(@self);
end;

function TPASimple.Write(data: Pointer; bytes: csize_t; error: pcint): cint;
begin
  Result := pa_simple_write(@self, data, bytes, error);
end;

function TPASimple.Drain(error: pcint): cint;
begin
  Result := pa_simple_drain(@Self, error);
end;

function TPASimple.Read(data: Pointer; bytes: csize_t; error: pcint): cint;
begin
  Result := pa_simple_read(@self, data, bytes, error);
end;

function TPASimple.GetLatency(error: pcint): QWord;
begin
  Result := pa_simple_get_latency(@self, error);
end;

function TPASimple.Flush(error: pcint): cint;
begin
  Result := pa_simple_flush(@self, error);
end;

end.

