{***
  This file is part of PulseAudio.

  Copyright 2004-2006 Lennart Poettering

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
unit pulse_operation;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, pulse_def;

type

{** An asynchronous operation object *}
  PPAOperation = ^TPAOperation;

  {** A callback for operation state changes *}
  TPAOperationNotifyCB = procedure(AOperation: PPAOperation; userdata: pointer);

  { TPAOperation }

  TPAOperation = object {sealed}
    function Ref: PPAOperation;
    procedure Unref;
    procedure Cancel;
    function GetState: TPAOperationState;
    procedure SetStateCallback(AValue: TPAOperationNotifyCB; AUserData: Pointer);
  end;


{** Increase the reference count by one *}
function pa_operation_ref(o: PPAOperation): PPAOperation external;

{** Decrease the reference count by one *}
procedure pa_operation_unref(o: PPAOperation) external;

{** Cancel the operation. Beware! This will not necessarily cancel the
 * execution of the operation on the server side. However it will make
 * sure that the callback associated with this operation will not be
 * called anymore, effectively disabling the operation from the client
 * side's view. *}
procedure pa_operation_cancel(o: PPAOperation) external;

{** Return the current status of the operation *}
function pa_operation_get_state(o: PPAOperation): TPAOperationState external;

{** Set the callback function that is called when the operation state
 * changes. Usually this is not necessary, since the functions that
 * create pa_operation objects already take a callback that is called
 * when the operation finishes. Registering a state change callback is
 * mainly useful, if you want to get called back also if the operation
 * gets cancelled. \since 4.0 *}
procedure pa_operation_set_state_callback(o: PPAOperation; cb: TPAOperationNotifyCB; userdata: pointer) external;

implementation

{ TPAOperation }

function TPAOperation.Ref: PPAOperation;
begin
  Result := pa_operation_ref(@self);
end;

procedure TPAOperation.Unref;
begin
  pa_operation_unref(@self);
end;

procedure TPAOperation.Cancel;
begin
  pa_operation_cancel(@self);
end;

function TPAOperation.GetState: TPAOperationState;
begin
  Result := pa_operation_get_state(@self);
end;

procedure TPAOperation.SetStateCallback(AValue: TPAOperationNotifyCB;
  AUserData: Pointer);
begin
  pa_operation_set_state_callback(@self, AValue, AUserData);
end;

end.

