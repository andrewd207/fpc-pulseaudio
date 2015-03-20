{***
  This file is part of PulseAudio.

  Copyright 2004-2006 Lennart Poettering
  Copyright 2006 Pierre Ossman <ossman@cendio.se> for Cendio AB

  PulseAudio is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation; either version 2.1 of the
  License, or (at your option) any later version.

  PulseAudio is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with PulseAudio; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA.
***}
unit pulse_timeval;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, ctypes;

type

  PPATimeval = ^ TPATimeval;

  { TPATimeval }

  TPATimeval = object sealed
  private
    function GetValue: QWord;
    procedure SetValue(AValue: QWord);
  public
    function GetTimeOfDay: PPATimeval;
    function Diff(B: PPATimeval): QWord;
    function Compare(ATV: PPATimeval): cint;
    function Age: QWord;
    function Add(uSec: QWord): PPATimeval;
    function Subtract(uSec: QWord): PPATimeval;
    property Value: QWord read GetValue write SetValue;
  end;


//** Return the current wallclock timestamp, just like UNIX gettimeofday(). */
function pa_gettimeofday(tv: PPATimeval): PPATimeval; external;

//** Calculate the difference between the two specified timeval
// * structs. */
function pa_timeval_diff({const} a : PPATimeval; {const} b : PPATimeval) : QWord; external;

//** Compare the two timeval structs and return 0 when equal, negative when a < b, positive otherwise */
function pa_timeval_cmp({const} a : PPATimeval; {const} b : PPATimeval) : cint; external;

//** Return the time difference between now and the specified timestamp */
function pa_timeval_age({const} tv: PPATimeval): QWord; external;

//** Add the specified time in microseconds to the specified timeval structure */
function pa_timeval_add(tv : PPATimeval; v: QWord): PPATimeval; external;

//** Subtract the specified time in microseconds to the specified timeval structure. \since 0.9.11 */
function pa_timeval_sub(tv : PPATimeval; v: QWord): PPATimeval; external;

//** Store the specified usec value in the timeval struct. \since 0.9.7 */
function pa_timeval_store(tv : PPATimeval; v: QWord): PPATimeval; external;

//** Load the specified tv value and return it in usec. \since 0.9.7 */
function pa_timeval_load({const} tv : PPATimeval): QWord; external;

implementation

{ TPATimeval }

function TPATimeval.GetValue: QWord;
begin
  Result := pa_timeval_load(@Self);
end;

procedure TPATimeval.SetValue(AValue: QWord);
begin
  pa_timeval_store(@Self, AValue);
end;

function TPATimeval.GetTimeOfDay: PPATimeval;
begin
  Result := pa_gettimeofday(@Self);
end;

function TPATimeval.Diff(B: PPATimeval): QWord;
begin
  Result := pa_timeval_diff(@Self, B);
end;

function TPATimeval.Compare(ATV: PPATimeval): cint;
begin
  Result := pa_timeval_cmp(@Self, ATV);
end;

function TPATimeval.Age: QWord;
begin
  Result := pa_timeval_age(@Self);
end;

function TPATimeval.Add(uSec: QWord): PPATimeval;
begin
  Result := pa_timeval_add(@Self, uSec);
end;

function TPATimeval.Subtract(uSec: QWord): PPATimeval;
begin
  Result := pa_timeval_sub(@Self, uSec);
end;

end.

