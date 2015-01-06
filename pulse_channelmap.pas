{***
  This file is part of PulseAudio.

  Copyright 2005-2006 Lennart Poettering
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
unit pulse_channelmap;

{$mode objfpc}{$H+}
{$PACKRECORDS C}
{$CALLING cdecl}

interface

uses
  Classes, SysUtils, pulse_sample, ctypes;

type
  {** A list of channel labels *}
  TPAChannelPosition = (
    cpINVALID = -1,
    cpMONO = 0,

    cpFRONT_LEFT,               {**< Apple, Dolby call this 'Left' *}
    cpFRONT_RIGHT,              {**< Apple, Dolby call this 'Right' *}
    cpFRONT_CENTER,             {**< Apple, Dolby call this 'Center' *}

{** \cond fulldocs *}
    cpLEFT = cpFRONT_LEFT,
    cpRIGHT = cpFRONT_RIGHT,
    cpCENTER = cpFRONT_CENTER,
{** \endcond *}

    cpREAR_CENTER,              {**< Microsoft calls this 'Back Center', Apple calls this 'Center Surround', Dolby calls this 'Surround Rear Center' *}
    cpREAR_LEFT,                {**< Microsoft calls this 'Back Left', Apple calls this 'Left Surround' (!), Dolby calls this 'Surround Rear Left'  *}
    cpREAR_RIGHT,               {**< Microsoft calls this 'Back Right', Apple calls this 'Right Surround' (!), Dolby calls this 'Surround Rear Right'  *}

    cpLFE,                      {**< Microsoft calls this 'Low Frequency', Apple calls this 'LFEScreen' *}
{** \cond fulldocs *}
    cpSUBWOOFER = cpLFE,
{** \endcond *}

    cpFRONT_LEFT_OF_CENTER,     {**< Apple, Dolby call this 'Left Center' *}
    cpFRONT_RIGHT_OF_CENTER,    {**< Apple, Dolby call this 'Right Center *}

    cpSIDE_LEFT,                {**< Apple calls this 'Left Surround Direct', Dolby calls this 'Surround Left' (!) *}
    cpSIDE_RIGHT,               {**< Apple calls this 'Right Surround Direct', Dolby calls this 'Surround Right' (!) *}

    cpAUX0,
    cpAUX1,
    cpAUX2,
    cpAUX3,
    cpAUX4,
    cpAUX5,
    cpAUX6,
    cpAUX7,
    cpAUX8,
    cpAUX9,
    cpAUX10,
    cpAUX11,
    cpAUX12,
    cpAUX13,
    cpAUX14,
    cpAUX15,
    cpAUX16,
    cpAUX17,
    cpAUX18,
    cpAUX19,
    cpAUX20,
    cpAUX21,
    cpAUX22,
    cpAUX23,
    cpAUX24,
    cpAUX25,
    cpAUX26,
    cpAUX27,
    cpAUX28,
    cpAUX29,
    cpAUX30,
    cpAUX31,

    cpTOP_CENTER,               {**< Apple calls this 'Top Center Surround' *}

    cpTOP_FRONT_LEFT,           {**< Apple calls this 'Vertical Height Left' *}
    cpTOP_FRONT_RIGHT,          {**< Apple calls this 'Vertical Height Right' *}
    cpTOP_FRONT_CENTER,         {**< Apple calls this 'Vertical Height Center' *}

    cpTOP_REAR_LEFT,            {**< Microsoft and Apple call this 'Top Back Left' *}
    cpTOP_REAR_RIGHT,           {**< Microsoft and Apple call this 'Top Back Right' *}
    cpTOP_REAR_CENTER,          {**< Microsoft and Apple call this 'Top Back Center' *}

    cpMAX);

  TPAChannelMapDef= (
    {**< The mapping from RFC3551, which is based on AIFF-C *}
    cmAIFF,
    {**< The default mapping used by ALSA. This mapping is probably
     * not too useful since ALSA's default channel mapping depends on
     * the device string used. *}
    cmALSA,
    {**< Only aux channels *}
    cmAUX,
    {**< Microsoft's WAVEFORMATEXTENSIBLE mapping. This mapping works
     * as if all LSBs of dwChannelMask are set.  *}
    cmWAVEEX,
    {**< The default channel mapping used by OSS as defined in the OSS
     * 4.0 API specs. This mapping is probably not too useful since
     * the OSS API has changed in this respect and no longer knows a
     * default channel mapping based on the number of channels. *}
    cmOSS,
    {**< Upper limit of valid channel mapping definitions *}
    cmDEF_MAX,
    {**< The default channel map *}
    cmDEFAULT = cmAIFF
    );

   TPAChannelPositionMask = QWord;

   PPAChannelMap = ^TPAChannelMap;

   { TPAChannelMap }

   TPAChannelMap = object sealed
     {**< Number of channels *}
     channels: Byte;
     {**< Channel labels *}
     map: array[0..PA_CHANNELS_MAX-1] of QWord;
     procedure Init;
     procedure InitMono;
     procedure InitStereo;
     procedure InitAuto(achannels: cunsigned; def: TPAChannelMapDef);
     procedure InitExtend(achannels: cunsigned; def: TPAChannelMapDef);
     function  snprint(s: PChar; l: csize_t): PChar;
     function  Equal(AChannelMap: PPAChannelMap): Boolean;
     function  Valid: Boolean;
     function  Compatible(spec: PPASampleSpec): Boolean;
     function  SuperSet(AMap: PPAChannelMap): Boolean;
     function  CanBalance: Boolean;
     function  CanFade: Boolean;
     function  ToName: PChar;
     function  ToPrettyName: PChar;
     function  HasPosition(position: QWord): Boolean;
     function  Mask: TPAChannelPositionMask;
   end;


{** Initialize the specified channel map and return a pointer to
  * it. The channel map will have a defined state but
  * pa_channel_map_valid() will fail for it. *}
function pa_channel_map_init(m: PPAChannelMap): PPAChannelMap external;

{** Initialize the specified channel map for monaural audio and return a pointer to it *}
function pa_channel_map_init_mono(m: PPAChannelMap): PPAChannelMap external;

{** Initialize the specified channel map for stereophonic audio and return a pointer to it *}
function pa_channel_map_init_stereo(m: PPAChannelMap): PPAChannelMap external;

{** Initialize the specified channel map for the specified number of
  * channels using default labels and return a pointer to it. This call
  * will fail (return NULL) if there is no default channel map known for this
  * specific number of channels and mapping. *}
function pa_channel_map_init_auto(m: PPAChannelMap; channels: cunsigned; def: TPAChannelMapDef): PPAChannelMap external;

{** Similar to pa_channel_map_init_auto() but instead of failing if no
  * default mapping is known with the specified parameters it will
  * synthesize a mapping based on a known mapping with fewer channels
  * and fill up the rest with AUX0...AUX31 channels  \since 0.9.11 *}
function pa_channel_map_init_extend(m: PPAChannelMap; channels: cunsigned; def: TPAChannelMapDef): PPAChannelMap external;

{** Return a text label for the specified channel position *}
function pa_channel_position_to_string(pos: QWord): PChar external; {const}

{** The inverse of pa_channel_position_to_string(). \since 0.9.16 *}
function pa_channel_position_from_string({const} s: PChar): QWord external;

{** Return a human readable text label for the specified channel position. \since 0.9.7 *}
function pa_channel_position_to_pretty_string(pos: QWord): PChar external;

{** The maximum length of strings returned by
  * pa_channel_map_snprint(). Please note that this value can change
  * with any release without warning and without being considered API
  * or ABI breakage. You should not use this definition anywhere where
  * it might become part of an ABI. *}
const
  PA_CHANNEL_MAP_SNPRINT_MAX = 336;

{** Make a human readable string from the specified channel map *}
function pa_channel_map_snprint(s: PChar; l: csize_t; {const} map: PPAChannelMap): PChar external;

{** Parse a channel position list or well-known mapping name into a
  * channel map structure. This turns the output of
  * pa_channel_map_snprint() and pa_channel_map_to_name() back into a
  * PPAChannelMap }
function pa_channel_map_parse(map: PPAChannelMap; {const} s: PChar): PPAChannelMap external;

{** Compare two channel maps. Return 1 if both match. *}
function pa_channel_map_equal({const} a: PPAChannelMap; {const} b: PPAChannelMap): cint external;

{** Return non-zero if the specified channel map is considered valid *}
function pa_channel_map_valid({const} map: PPAChannelMap): cint external;

{** Return non-zero if the specified channel map is compatible with
  * the specified sample spec. \since 0.9.12 *}
function pa_channel_map_compatible({const} map: PPAChannelMap; {const} ss: PPASampleSpec ): cint external;

{** Returns non-zero if every channel defined in b is also defined in a. \since 0.9.15 *}
function pa_channel_map_superset({const} a: PPAChannelMap; {const} b: PPAChannelMap): cint external;

{** Returns non-zero if it makes sense to apply a volume 'balance'
  * with this mapping, i.e.\ if there are left/right channels
  * available. \since 0.9.15 *}
function pa_channel_map_can_balance({const} map: PPAChannelMap): cint external;

{** Returns non-zero if it makes sense to apply a volume 'fade'
  * (i.e.\ 'balance' between front and rear) with this mapping, i.e.\ if
  * there are front/rear channels available. \since 0.9.15 *}
function pa_channel_map_can_fade({const} map: PPAChannelMap): cint external;

{** Tries to find a well-known channel mapping name for this channel
  * mapping, i.e.\ "stereo", "surround-71" and so on. If the channel
  * mapping is unknown NULL will be returned. This name can be parsed
  * with pa_channel_map_parse() \since 0.9.15 *}
function pa_channel_map_to_name({const} map: PPAChannelMap): PChar external;

{** Tries to find a human readable text label for this channel
    mapping, i.e.\ "Stereo", "Surround 7.1" and so on. If the channel
    mapping is unknown NULL will be returned. \since 0.9.15 *}
function pa_channel_map_to_pretty_name({const} map: PPAChannelMap): PChar external;

{** Returns non-zero if the specified channel position is available at
  * least once in the channel map. \since 0.9.16 *}
function pa_channel_map_has_position({const} map: PPAChannelMap; p: QWord): cint external;

{** Generates a bit mask from a channel map. \since 0.9.16 *}
function pa_channel_map_mask({const} map: PPAChannelMap): TPAChannelPositionMask external;

implementation

{ TPAChannelMap }

procedure TPAChannelMap.Init;
begin
  pa_channel_map_init(@self);
end;

procedure TPAChannelMap.InitMono;
begin
  pa_channel_map_init_mono(@self);
end;

procedure TPAChannelMap.InitStereo;
begin
  pa_channel_map_init_stereo(@self);
end;

procedure TPAChannelMap.InitAuto(achannels: cunsigned; def: TPAChannelMapDef);
begin
  pa_channel_map_init_auto(@self, achannels, def);
end;

procedure TPAChannelMap.InitExtend(achannels: cunsigned; def: TPAChannelMapDef);
begin
  pa_channel_map_init_extend(@self, achannels, def);
end;

function TPAChannelMap.snprint(s: PChar; l: csize_t): PChar;
begin
  result := pa_channel_map_snprint(s,l,@self);
end;

function TPAChannelMap.Equal(AChannelMap: PPAChannelMap): Boolean;
begin
  result := pa_channel_map_equal(@self, AChannelMap) = 1;
end;

function TPAChannelMap.Valid: Boolean;
begin
  result := pa_channel_map_valid(@self) <> 0;
end;

function TPAChannelMap.Compatible(spec: PPASampleSpec): Boolean;
begin
  result := pa_channel_map_compatible(@self,spec) <> 0;
end;

function TPAChannelMap.SuperSet(AMap: PPAChannelMap): Boolean;
begin
  result := pa_channel_map_superset(@self, AMap) <> 0;
end;

function TPAChannelMap.CanBalance: Boolean;
begin
  result := pa_channel_map_can_balance(@self) <> 0;
end;

function TPAChannelMap.CanFade: Boolean;
begin
  result := pa_channel_map_can_fade(@self) <> 0;
end;

function TPAChannelMap.ToName: PChar;
begin
  result := pa_channel_map_to_name(@self);
end;

function TPAChannelMap.ToPrettyName: PChar;
begin
  result := pa_channel_map_to_pretty_name(@self);
end;

function TPAChannelMap.HasPosition(position: QWord): Boolean;
begin
  result := pa_channel_map_has_position(@self, position) <> 0;
end;

function TPAChannelMap.Mask: TPAChannelPositionMask;
begin
  result := pa_channel_map_mask(@self);
end;

end.

