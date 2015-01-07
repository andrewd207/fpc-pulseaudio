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
unit pulse_scache;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, pulse_context, pulse_stream, pulse_operation, pulse_volume,
  pulse_proplist, ctypes;

type
{** Callback prototype for pa_context_play_sample_with_proplist(). The
 * idx value is the index of the sink input object, or
 * PA_INVALID_INDEX on failure. \since 0.9.11 *}
  TPAContextPlaySampleCB = procedure (c: PPAContext; idx: Longword; userdata: pointer);

{** Make this stream a sample upload stream *}
function pa_stream_connect_upload(s: PPAStream; length: csize_t): cint external;

{** Finish the sample upload, the stream name will become the sample
 * name. You cancel a sample upload by issuing
 * pa_stream_disconnect() *}
function pa_stream_finish_upload(s: PPAStream): cint external;

{** Remove a sample from the sample cache. Returns an operation object which may be used to cancel the operation while it is running *}
function pa_context_remove_sample(c: PPAContext; {const} name: PChar; cb: TPAContextSuccessCB; userdata: pointer): PPAOperation external;

{** Play a sample from the sample cache to the specified device. If
 * the latter is NULL use the default sink. Returns an operation
 * object *}
function pa_context_play_sample(
        c: PPAContext               {**< Context *};
        {const} name: PChar            {**< Name of the sample to play *};
        {const} dev: PChar             {**< Sink to play this sample on *};
        volumn: TPAVolume          {**< Volume to play this sample with. Starting with 0.9.15 you may pass here PA_VOLUME_INVALID which will leave the decision about the volume to the server side which is a good idea. *} ;
        cb: TPAContextSuccessCB  {**< Call this function after successfully starting playback, or NULL *};
        userdata: pointer              {**< Userdata to pass to the callback *}
        ): PPAOperation external;

{** Play a sample from the sample cache to the specified device,
 * allowing specification of a property list for the playback
 * stream. If the latter is NULL use the default sink. Returns an
 * operation object. \since 0.9.11 *}
function pa_context_play_sample_with_proplist(
        c: PPAContext               {**< Context *};
        {const} name: PChar         {**< Name of the sample to play *};
        {const} dev: PChar          {**< Sink to play this sample on *};
        volumn: TPAVolume           {**< Volume to play this sample with. Starting with 0.9.15 you may pass here PA_VOLUME_INVALID which will leave the decision about the volume to the server side which is a good idea.  *} ;
        proplist: PPAProplist       {**< Property list for this sound. The property list of the cached entry will be merged into this property list *};
        cb: TPAContextPlaySampleCB  {**< Call this function after successfully starting playback, or NULL *};
        userdata: pointer           {**< Userdata to pass to the callback *}
        ): PPAOperation external;

implementation

end.

