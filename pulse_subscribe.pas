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
unit pulse_subscribe;

{$mode objfpc}{$H+}
{$PACKRECORDS c}
{$CALLING cdecl}

interface

uses
  Classes, SysUtils, pulse_context, pulse_def, pulse_operation;

type
{** \file
 * Daemon introspection event subscription subsystem.
 *
 * See also \subpage subscribe
 *}

{** Subscription event callback prototype *}
  TPAContextSubscribeCB = procedure (c: PPAContext; t: TPASubcriptionEventType; idx: Longword; userdata: pointer);

{** Enable event notification *}
function pa_context_subscribe(c: PPAContext; m: TPASubscriptionMask; cb: TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Set the context specific call back function that is called whenever the state of the daemon changes *}
procedure pa_context_set_subscribe_callback(c: PPAContext; cb: TPAContextSubscribeCB; userdata: pointer) external;

implementation

end.

