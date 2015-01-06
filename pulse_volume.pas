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

unit pulse_volume;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}

interface

uses
  Classes, SysUtils, pulse_sample, pulse_channelmap, ctypes;

{** Volume specification:
 *  PA_VOLUME_MUTED: silence;
 * < PA_VOLUME_NORM: decreased volume;
 *   PA_VOLUME_NORM: normal volume;
 * > PA_VOLUME_NORM: increased volume *}

type
  TPAVolume = longword;

const
{** Normal volume (100%, 0 dB) *}
  PA_VOLUME_NORM = $10000;

{** Muted (minimal valid) volume (0%, -inf dB) *}
  PA_VOLUME_MUTED = 0;

{** Maximum valid volume we can store. \since 0.9.15 *}
  PA_VOLUME_MAX  = $FFFFFFFF div 2;

{** Special 'invalid' volume. \since 0.9.16 *}
  PA_VOLUME_INVALID = $FFFFFFFF;


// TODO implement Macros as functions
(*{** Check if volume is valid. \since 1.0 *}
  PA_VOLUME_IS_VALID(v) ((v) <= PA_VOLUME_MAX)

{** Clamp volume to the permitted range. \since 1.0 *}
  PA_CLAMP_VOLUME(v) (PA_CLAMP_UNLIKELY((v), PA_VOLUME_MUTED, PA_VOLUME_MAX))
*)

type
{** A structure encapsulating a per-channel volume *}
  PPAChannelVolume = ^TPAChannelVolume;

  { TPAChannelVolume }

  TPAChannelVolume = object sealed
    channels: Byte;                     {**< Number of channels *}
    Values: array[0..PA_CHANNELS_MAX-1] of TPAVolume;{**< Per-channel volume *}
    function  Equal(AChannelVolume: PPAChannelVolume): Boolean;
    function  Init: PPAChannelVolume; // returns self
    procedure Reset(AChannels: cunsigned); // returns to PA_VOLUME_NORM
    procedure Mute(AChannels: cunsigned);
    function  SetVolume(AChannels: cunsigned; AValue: TPAVolume): PPAChannelVolume;
    function  snprint(s: PChar; l: csize_t): PChar;
    function  snprint_verbose(s: PChar; l: csize_t; AMap: PPAChannelMap; print_dB: Boolean): PChar;
    function  Average: TPAVolume;
    function  AverageMask(AMap: PPAChannelMap; AMask: TPAChannelPositionMask): TPAVolume;
    function  Max: TPAVolume;
    function  MaxMask(AMap: PPAChannelMap; AMask: TPAChannelPositionMask): TPAVolume;
    function  Min: TPAVolume;
    function  MinMask(AMap: PPAChannelMap; AMask: TPAChannelPositionMask): TPAVolume;
    function  Valid: Boolean;
    function  ChannelsEqualTo(AVolume: TPAVolume): Boolean;
    function  IsMuted: Boolean;
    function  IsNormal: Boolean;
    function  Remap(AFrom, ATo: PPAChannelMap): PPAChannelVolume;
    function  Compatible(ASpec: PPASampleSpec): Boolean;
    function  CompatibleWithChannelMap(AMap: PPAChannelMap): Boolean;
    function  GetBalance(AMap: PPAChannelMap): cfloat;
    function  SetBalance(AMap: PPAChannelMap; ANewBalance: cfloat): PPAChannelVolume;
    function  GetFade(AMap: PPAChannelMap): cfloat;
    function  SetFade(AMap: PPAChannelMap; AFadeValue: cfloat): PPAChannelVolume;
    function  Scale(AMax: TPAVolume): PPAChannelVolume;
    function  ScaleMask(AMax: TPAVolume; AMap: PPAChannelMap; AMask: TPAChannelPositionMask): PPAChannelVolume;
    function  SetPosition(AMap: PPAChannelMap; T: TPAChannelPosition; AValue: TPAVolume): PPAChannelVolume;
    function  GetPosition(AMap: PPAChannelMap; T: TPAChannelPosition): TPAVolume;
    function  Merge(AWith, Dest: PPAChannelVolume): PPAChannelVolume; // Dest can be self
    function  IncreaseWithClamp(AIncreaseBy: TPAVolume; ALimit: TPAVolume): PPAChannelVolume;
    function  Increase(AIncreaseBy: TPAVolume): PPAChannelVolume;
    function  Decrease(ADecreaseBy: TPAVolume): PPAChannelVolume;
  end;

{** Return non-zero when *a == *b *}
function pa_cvolume_equal({const} a: PPAChannelVolume; {const} b: PPAChannelVolume): cint external;

{** Initialize the specified volume and return a pointer to
 * it. The sample spec will have a defined state but
 * pa_cvolume_valid() will fail for it. \since 0.9.13 *}
function pa_cvolume_init(a: PPAChannelVolume): PPAChannelVolume external;

//Implemented in Object ( MACROS )
(*
{** Set the volume of the first n channels to PA_VOLUME_NORM *}
  pa_cvolume_reset(a, n) pa_cvolume_set((a), (n), PA_VOLUME_NORM)

{** Set the volume of the first n channels to PA_VOLUME_MUTED *}
  pa_cvolume_mute(a, n) pa_cvolume_set((a), (n), PA_VOLUME_MUTED)
*)

{** Set the volume of the specified number of channels to the volume v *}
function pa_cvolume_set(a: PPAChannelVolume; channels: cunsigned; v: TPAVolume): PPAChannelVolume external;

{** Maximum length of the strings returned by
 * pa_cvolume_snprint(). Please note that this value can change with
 * any release without warning and without being considered API or ABI
 * breakage. You should not use this definition anywhere where it
 * might become part of an ABI.*}
const
  PA_CVOLUME_SNPRINT_MAX = 320;

{** Pretty print a volume structure *}
function pa_cvolume_snprint(s: PChar; l: csize_t; {const} c: PPAChannelVolume): PChar external;

{** Maximum length of the strings returned by
 * pa_sw_cvolume_snprint_dB(). Please note that this value can change with
 * any release without warning and without being considered API or ABI
 * breakage. You should not use this definition anywhere where it
 * might become part of an ABI. \since 0.9.13 *}
const
  PA_SW_CVOLUME_SNPRINT_DB_MAX = 448;

{** Pretty print a volume structure but show dB values. \since 0.9.13 *}
function pa_sw_cvolume_snprint_dB(s: PChar; l: csize_t; {const} c: PPAChannelVolume): PChar external;

{** Maximum length of the strings returned by pa_cvolume_snprint_verbose().
 * Please note that this value can change with any release without warning and
 * without being considered API or ABI breakage. You should not use this
 * definition anywhere where it might become part of an ABI. \since 5.0 *}
const
  PA_CVOLUME_SNPRINT_VERBOSE_MAX = 1984;

{** Pretty print a volume structure in a verbose way. The volume for each
 * channel is printed in several formats: the raw v: TPAVolumealue,
 * percentage, and if print_dB is non-zero, also the dB value. If map is not
 * NULL, the channel names will be printed. \since 5.0 *}
function pa_cvolume_snprint_verbose(s: PChar; l: csize_t; {const} c: PPAChannelVolume; {const} map: PPAChannelMap; print_dB: cint): pchar external;

{** Maximum length of the strings returned by
 * pa_volume_snprint(). Please note that this value can change with
 * any release without warning and without being considered API or ABI
 * breakage. You should not use this definition anywhere where it
 * might become part of an ABI. \since 0.9.15 *}
const
  PA_VOLUME_SNPRINT_MAX = 10;

{** Pretty print a volume \since 0.9.15 *}
function pa_volume_snprint(s: PChar; l: csize_t; v: TPAVolume): pchar external;

{** Maximum length of the strings returned by
 * pa_sw_volume_snprint_dB(). Please note that this value can change with
 * any release without warning and without being considered API or ABI
 * breakage. You should not use this definition anywhere where it
 * might become part of an ABI. \since 0.9.15 *}
const
  PA_SW_VOLUME_SNPRINT_DB_MAX = 10;

{** Pretty print a volume but show dB values. \since 0.9.15 *}
function pa_sw_volume_snprint_dB(s: PChar; l: csize_t; v: TPAVolume): pchar external;

{** Maximum length of the strings returned by pa_volume_snprint_verbose().
 * Please note that this value can change with any release without warning and
 * withou being considered API or ABI breakage. You should not use this
 * definition anywhere where it might become part of an ABI. \since 5.0 *}
const
  PA_VOLUME_SNPRINT_VERBOSE_MAX = 35;

{** Pretty print a volume in a verbose way. The volume is printed in several
 * formats: the raw v: TPAVolumealue, percentage, and if print_dB is non-zero,
 * also the dB value. \since 5.0 *}
function pa_volume_snprint_verbose(s: PChar; l: csize_t; v: TPAVolume; print_dB: cint): pchar external;

{** Return the average volume of all channels *}
function pa_cvolume_avg({const} a: PPAChannelVolume): TPAVolume external;

{** Return the average volume of all channels that are included in the
 * specified channel map with the specified channel position mask. If
 * cm is NULL this call is identical to pa_cvolume_avg(). If no
 * channel is selected the returned value will be
 * PA_VOLUME_MUTED. \since 0.9.16 *}
function pa_cvolume_avg_mask({const} a: PPAChannelVolume; {const} cm: PPAChannelMap; mask: TPAChannelPositionMask): TPAVolume external;

{** Return the maximum volume of all channels. \since 0.9.12 *}
function  pa_cvolume_max({const} a: PPAChannelVolume): TPAVolume external;

{** Return the maximum volume of all channels that are included in the
 * specified channel map with the specified channel position mask. If
 * cm is NULL this call is identical to pa_cvolume_max(). If no
 * channel is selected the returned value will be PA_VOLUME_MUTED.
 * \since 0.9.16 *}
function pa_cvolume_max_mask({const} a: PPAChannelVolume; {const} cm: PPAChannelMap; mask: TPAChannelPositionMask): TPAVolume external;

{** Return the minimum volume of all channels. \since 0.9.16 *}
function pa_cvolume_min({const} a: PPAChannelVolume): TPAVolume external;

{** Return the minimum volume of all channels that are included in the
 * specified channel map with the specified channel position mask. If
 * cm is NULL this call is identical to pa_cvolume_min(). If no
 * channel is selected the returned value will be PA_VOLUME_MUTED.
 * \since 0.9.16 *}
function pa_cvolume_min_mask({const} a: PPAChannelVolume; {const} cm: PPAChannelMap; mask: TPAChannelPositionMask): TPAVolume external;

{** Return non-zero when the passed cvolume structure is valid *}
function pa_cvolume_valid({const} v: PPAChannelVolume): cint external;

{** Return non-zero if the volume of all channels is equal to the specified value *}
function pa_cvolume_channels_equal_to({const} a: PPAChannelVolume; v: TPAVolume): cint external;


(* TODO Macros
{** Return 1 if the specified volume has all channels muted *}
  pa_cvolume_is_muted(a) pa_cvolume_channels_equal_to((a), PA_VOLUME_MUTED)

{** Return 1 if the specified volume has all channels on normal level *}
  pa_cvolume_is_norm(a) pa_cvolume_channels_equal_to((a), PA_VOLUME_NORM)

*)

{** Multiply two volume specifications, return the result. This uses
 * PA_VOLUME_NORM as neutral element of multiplication. This is only
 * valid for software volumes! *}
function pa_sw_volume_multiply(a: TPAVolume; b: TPAVolume): TPAVolume external;

{** Multiply two per-channel volumes and return the result in
 * *dest. This is only valid for software volumes! a, b and dest may
 * point to the same structure. *}
function pa_sw_cvolume_multiply(dest: PPAChannelVolume; {const} a: PPAChannelVolume; {const} b: PPAChannelVolume): PPAChannelVolume external;

{** Multiply a per-channel volume with a scalar volume and return the
 * result in *dest. This is only valid for software volumes! a
 * and dest may point to the same structure. \since
 * 0.9.16 *}
function pa_sw_cvolume_multiply_scalar(dest: PPAChannelVolume; {const} a: PPAChannelVolume; b: TPAVolume): PPAChannelVolume external;

{** Divide two volume specifications, return the result. This uses
 * PA_VOLUME_NORM as neutral element of division. This is only valid
 * for software volumes! If a division by zero is tried the result
 * will be 0. \since 0.9.13 *}
function pa_sw_volume_divide(a: TPAVolume; b: TPAVolume) : TPAVolume external;

{** Divide two per-channel volumes and return the result in
 * *dest. This is only valid for software volumes! a, b
 * and dest may point to the same structure. \since 0.9.13 *}
function pa_sw_cvolume_divide(dest: PPAChannelVolume; {const} a: PPAChannelVolume; {const} b: PPAChannelVolume): PPAChannelVolume external;

{** Divide a per-channel volume by a scalar volume and return the
 * result in *dest. This is only valid for software volumes! a
 * and dest may point to the same structure. \since
 * 0.9.16 *}
function pa_sw_cvolume_divide_scalar(dest: PPAChannelVolume; {const} a: PPAChannelVolume; b: TPAVolume): PPAChannelVolume external;

{** Convert a decibel value to a volume (amplitude, not power). This is only valid for software volumes! *}
function pa_sw_volume_from_dB(f: cdouble) : TPAVolume external;

{** Recommended maximum volume to show in user facing UIs.
 * Note: UIs should deal gracefully with volumes greater than this value
 * and not cause feedback loops etc. - i.e. if the volume is more than
 * this, the UI should not limit it and push the limited value back to
 * the server. \since 0.9.23 *}
function pa_volume_ui_max: TPAVolume; // was macro

{** Convert a volume to a decibel value (amplitude, not power). This is only valid for software volumes! *}
function pa_sw_volume_to_dB(v: TPAVolume) : cdouble external;

{** Convert a linear factor to a volume.  0.0 and less is muted while
 * 1.0 is PA_VOLUME_NORM.  This is only valid for software volumes! *}
function pa_sw_volume_from_linear(v: cdouble): TPAVolume external;

{** Convert a volume to a linear factor. This is only valid for software volumes! *}
function pa_sw_volume_to_linear(v: TPAVolume): cdouble external;

(* What to do here? Possibly internal to pulse
#ifdef INFINITY
  PA_DECIBEL_MININFTY ((double) -INFINITY)
#else
{** This floor value is used as minus infinity when using pa_sw_volume_to_dB() / pa_sw_volume_from_dB(). *}
  PA_DECIBEL_MININFTY ((double) -200.0)
#endif
*)
{** Remap a volume from one channel mapping to a different channel mapping. \since 0.9.12 *}
function pa_cvolume_remap(v: PPAChannelVolume; {const} from: PPAChannelMap; {const} to_: PPAChannelMap): PPAChannelVolume external;

{** Return non-zero if the specified volume is compatible with the
 * specified sample spec. \since 0.9.13 *}
function pa_cvolume_compatible({const} v: PPAChannelVolume; {const} ss: PPASampleSpec): cint external;

{** Return non-zero if the specified volume is compatible with the
 * specified sample spec. \since 0.9.15 *}
function pa_cvolume_compatible_with_channel_map({const} v: PPAChannelVolume; {const} cm: PPAChannelMap): cint external;

{** Calculate a 'balance' value for the specified volume with the
 * specified channel map. The return value will range from -1.0f
 * (left) to +1.0f (right). If no balance value is applicable to this
 * channel map the return value will always be 0.0f. See
 * pa_channel_map_can_balance(). \since 0.9.15 *}
function pa_cvolume_get_balance({const} v: PPAChannelVolume; {const} map: PPAChannelMap): cfloat external;

{** Adjust the 'balance' value for the specified volume with the
 * specified channel map. v will be modified in place and
 * returned. The balance is a value between -1.0f and +1.0f. This
 * operation might not be reversible! Also, after this call
 * pa_cvolume_get_balance() is not guaranteed to actually return the
 * requested balance value (e.g. when the input volume was zero anyway for
 * all channels). If no balance value is applicable to
 * this channel map the volume will not be modified. See
 * pa_channel_map_can_balance(). \since 0.9.15 *}
function pa_cvolume_set_balance(v: PPAChannelVolume; {const} map: PPAChannelMap; new_balance: cfloat): PPAChannelVolume external;

{** Calculate a 'fade' value (i.e.\ 'balance' between front and rear)
 * for the specified volume with the specified channel map. The return
 * value will range from -1.0f (rear) to +1.0f (left). If no fade
 * value is applicable to this channel map the return value will
 * always be 0.0f. See pa_channel_map_can_fade(). \since 0.9.15 *}
function pa_cvolume_get_fade({const} v: PPAChannelVolume; {const} map: PPAChannelMap): cfloat external;

{** Adjust the 'fade' value (i.e.\ 'balance' between front and rear)
 * for the specified volume with the specified channel map. v will be
 * modified in place and returned. The balance is a value between
 * -1.0f and +1.0f. This operation might not be reversible! Also,
 * after this call pa_cvolume_get_fade() is not guaranteed to actually
 * return the requested fade value (e.g. when the input volume was
 * zero anyway for all channels). If no fade value is applicable to
 * this channel map the volume will not be modified. See
 * pa_channel_map_can_fade(). \since 0.9.15 *}
function pa_cvolume_set_fade(v: PPAChannelVolume; {const} map: PPAChannelMap; new_fade: cfloat): PPAChannelVolume external;

{** Scale the passed pa_cvolume structure so that the maximum volume
 * of all channels equals max. The proportions between the channel
 * volumes are kept. \since 0.9.15 *}
function pa_cvolume_scale(v: PPAChannelVolume; max: TPAVolume): PPAChannelVolume external;

{** Scale the passed pa_cvolume structure so that the maximum volume
 * of all channels selected via cm/mask equals max. This also modifies
 * the volume of those channels that are unmasked. The proportions
 * between the channel volumes are kept. \since 0.9.16 *}
function pa_cvolume_scale_mask(v: PPAChannelVolume; max: TPAVolume; cm: PPAChannelMap; mask: TPAChannelPositionMask): PPAChannelVolume external;

{** Set the passed volume to all channels at the specified channel
 * position. Will return the updated volume struct, or NULL if there
 * is no channel at the position specified. You can check if a channel
 * map includes a specific position by calling
 * pa_channel_map_has_position(). \since 0.9.16 *}
function pa_cvolume_set_position(cp: PPAChannelVolume; {const} map: PPAChannelMap; t: TPAChannelPosition; v: TPAVolume): PPAChannelVolume external;

{** Get the maximum volume of all channels at the specified channel
 * position. Will return 0 if there is no channel at the position
 * specified. You can check if a channel map includes a specific
 * position by calling pa_channel_map_has_position(). \since 0.9.16 *}
function pa_cvolume_get_position(cv: PPAChannelVolume; {const} map: PPAChannelMap; t: TPAChannelPosition): TPAVolume external;

{** This goes through all channels in a and b and sets the
 * corresponding channel in dest to the greater volume of both. a, b
 * and dest may point to the same structure. \since 0.9.16 *}
function pa_cvolume_merge(dest: PPAChannelVolume; {const} a: PPAChannelVolume; {const} b: PPAChannelVolume): PPAChannelVolume external;

{** Increase the volume passed in by 'inc', but not exceeding 'limit'.
 * The proportions between the channels are kept. \since 0.9.19 *}
function pa_cvolume_inc_clamp(v: PPAChannelVolume; inc, limit: TPAVolume): PPAChannelVolume external;

{** Increase the volume passed in by 'inc'. The proportions between
 * the channels are kept. \since 0.9.16 *}
function pa_cvolume_inc(v: PPAChannelVolume; inc: TPAVolume): PPAChannelVolume external;

{** Decrease the volume passed in by 'dec'. The proportions between
 * the channels are kept. \since 0.9.16 *}
function pa_cvolume_dec(v: PPAChannelVolume; dec: TPAVolume): PPAChannelVolume external;

implementation

function pa_volume_ui_max: TPAVolume;
begin
  result := pa_sw_volume_from_dB(+11.0);
end;

{ TPAChannelVolume }

function TPAChannelVolume.Equal(AChannelVolume: PPAChannelVolume): Boolean;
begin
  Result := pa_cvolume_equal(@self, AChannelVolume) <> 0;
end;

function TPAChannelVolume.Init: PPAChannelVolume;
begin
  Result := pa_cvolume_init(@self);
end;

procedure TPAChannelVolume.Reset(AChannels: cunsigned);
begin
  pa_cvolume_set(@self, AChannels, PA_VOLUME_NORM);
end;

procedure TPAChannelVolume.Mute(AChannels: cunsigned);
begin
  pa_cvolume_set(@self, AChannels, PA_VOLUME_MUTED);
end;

function TPAChannelVolume.SetVolume(AChannels: cunsigned; AValue: TPAVolume
  ): PPAChannelVolume;
begin
  Result := pa_cvolume_set(@self, AChannels, AValue);
end;

function TPAChannelVolume.snprint(s: PChar; l: csize_t): PChar;
begin
  Result := pa_cvolume_snprint(s,l,@self);
end;

function TPAChannelVolume.snprint_verbose(s: PChar; l: csize_t;
  AMap: PPAChannelMap; print_dB: Boolean): PChar;
begin
  Result := pa_cvolume_snprint_verbose(s,l,@self,AMap,ord(print_dB));
end;

function TPAChannelVolume.Average: TPAVolume;
begin
  Result := pa_cvolume_avg(@self);
end;

function TPAChannelVolume.AverageMask(AMap: PPAChannelMap;
  AMask: TPAChannelPositionMask): TPAVolume;
begin
  Result := pa_cvolume_avg_mask(@self,AMap, AMask);
end;

function TPAChannelVolume.Max: TPAVolume;
begin
  Result := pa_cvolume_max(@Self);

end;

function TPAChannelVolume.MaxMask(AMap: PPAChannelMap;
  AMask: TPAChannelPositionMask): TPAVolume;
begin
  Result := pa_cvolume_max_mask(@self, AMap, AMask);

end;

function TPAChannelVolume.Min: TPAVolume;
begin
  Result := pa_cvolume_min(@self);
end;

function TPAChannelVolume.MinMask(AMap: PPAChannelMap;
  AMask: TPAChannelPositionMask): TPAVolume;
begin
  Result := pa_cvolume_min_mask(@self, AMap, AMask);
end;

function TPAChannelVolume.Valid: Boolean;
begin
  Result := pa_cvolume_valid(@self) <> 0;
end;

function TPAChannelVolume.ChannelsEqualTo(AVolume: TPAVolume): Boolean;
begin
  Result := pa_cvolume_channels_equal_to(@self, AVolume) <> 0;
end;

function TPAChannelVolume.IsMuted: Boolean;
begin
  Result := pa_cvolume_channels_equal_to(@self, PA_VOLUME_MUTED) = 1;
end;

function TPAChannelVolume.IsNormal: Boolean;
begin
  Result := pa_cvolume_channels_equal_to(@self, PA_VOLUME_NORM) = 1;
end;

function TPAChannelVolume.Remap(AFrom, ATo: PPAChannelMap): PPAChannelVolume;
begin
  Result := pa_cvolume_remap(@Self,AFrom, ATo);
end;

function TPAChannelVolume.Compatible(ASpec: PPASampleSpec): Boolean;
begin
  Result := pa_cvolume_compatible(@Self, ASpec) <> 0;
end;

function TPAChannelVolume.CompatibleWithChannelMap(AMap: PPAChannelMap
  ): Boolean;
begin
  Result := pa_cvolume_compatible_with_channel_map(@self, AMap) <> 0;
end;

function TPAChannelVolume.GetBalance(AMap: PPAChannelMap): cfloat;
begin
  Result := pa_cvolume_get_balance(@self, AMap);
end;

function TPAChannelVolume.SetBalance(AMap: PPAChannelMap; ANewBalance: cfloat
  ): PPAChannelVolume;
begin
  Result := pa_cvolume_set_balance(@self, AMap, ANewBalance);
end;

function TPAChannelVolume.GetFade(AMap: PPAChannelMap): cfloat;
begin
  Result := pa_cvolume_get_fade(@self, AMap);
end;

function TPAChannelVolume.SetFade(AMap: PPAChannelMap; AFadeValue: cfloat
  ): PPAChannelVolume;
begin
  Result := pa_cvolume_set_fade(@self, AMap, AFadeValue);
end;

function TPAChannelVolume.Scale(AMax: TPAVolume): PPAChannelVolume;
begin
  Result := pa_cvolume_scale(@self, AMax);
end;

function TPAChannelVolume.ScaleMask(AMax: TPAVolume; AMap: PPAChannelMap;
  AMask: TPAChannelPositionMask): PPAChannelVolume;
begin
  Result := pa_cvolume_scale_mask(@self, AMax, AMap, AMask);
end;

function TPAChannelVolume.SetPosition(AMap: PPAChannelMap;
  T: TPAChannelPosition; AValue: TPAVolume): PPAChannelVolume;
begin
  Result := pa_cvolume_set_position(@self, AMap, T, AValue);
end;

function TPAChannelVolume.GetPosition(AMap: PPAChannelMap; T: TPAChannelPosition
  ): TPAVolume;
begin
  Result := pa_cvolume_get_position(@Self, AMap, T);
end;

function TPAChannelVolume.Merge(AWith, Dest: PPAChannelVolume
  ): PPAChannelVolume;
begin
  Result := pa_cvolume_merge(dest, @Self, AWith);
end;

function TPAChannelVolume.IncreaseWithClamp(AIncreaseBy: TPAVolume;
  ALimit: TPAVolume): PPAChannelVolume;
begin
  Result := pa_cvolume_inc_clamp(@self, AIncreaseBy, ALimit);
end;

function TPAChannelVolume.Increase(AIncreaseBy: TPAVolume): PPAChannelVolume;
begin
  Result := pa_cvolume_inc(@self, AIncreaseBy);
end;

function TPAChannelVolume.Decrease(ADecreaseBy: TPAVolume): PPAChannelVolume;
begin
  Result := pa_cvolume_dec(@self, ADecreaseBy);
end;

end.

