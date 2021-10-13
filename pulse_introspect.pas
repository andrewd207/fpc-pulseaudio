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
unit pulse_introspect;

{$mode objfpc}{$H+}
{$CALLING CDECL}
{$PACKRECORDS c}
{$modeswitch advancedrecords}


interface

uses
  Classes, SysUtils, ctypes,
  dynlibs,
  pulse_context,
  pulse_operation,
  pulse_sample,
  pulse_channelmap,
  pulse_volume,
  pulse_def,
  pulse_proplist,
  pulse_format;
type

  PPPASinkPortInfo = ^PPASinkPortInfo;
  PPASinkPortInfo = ^TPASinkPortInfo;
  TPASinkPortInfo = record
    name: PChar;
    description: PChar;
    priority: cuint32;
    available: cint;
    availability_group: PChar;
    type_: cuint32;
  end;

  PPASinkInfo = ^TPASinkInfo;
  TPASinkInfo = record
    name: PChar;
    index: cuint32;
    description: PChar;
    sample_spec: TPASampleSpec;
    channel_map: TPAChannelMap;
    owner_module: cuint32;
    volume: TPAChannelVolume;
    mute: cint;
    monitor_source: cuint32;
    monitor_source_name: PChar;
    latency: QWord;
    driver: PChar;
    flags: Word; // TODO correct?
    proplist: PPAProplist;
    configured_latency: QWord;
    base_volume: TPAVolume;
    state: TPASinkState;
    n_volume_steps: cuint32;
    card: cuint32;
    n_ports: cuint32;
    ports: PPPASinkPortInfo;
    active_port: PPASinkPortInfo;
    n_formats: cuint8;
    formats: PPPAFormatInfo;
  end;

  PPPASourcePortInfo = ^PPASourcePortInfo;
  PPASourcePortInfo = ^TPASourcePortInfo;
  TPASourcePortInfo = record
    name: PChar;
    description: PChar;
    priority: cuint32;
    available: cint;
    availability_group: PChar;
    type_: cuint32;
  end;

  PPASourceInfo = ^TPASourceInfo;
  TPASourceInfo = record
    name: PChar;
    index: cuint32;
    description: PChar;
    sample_spec: TPASampleSpec;
    channel_map: TPAChannelMap;
    owner_module: cuint32;
    volume: TPAChannelVolume;
    mute: cint;
    monitor_of_sink: cuint32;
    monitor_of_sink_name: PChar;
    latency: QWord;
    driver: PChar;
    flags: Word; // TODO correct?
    proplist: PPAProplist;
    configured_latency: QWord;
    base_volume: TPAVolume;
    state: TPASourceState;
    n_volume_steps: cuint32;
    card: cuint32;
    n_ports: cuint32;
    ports: PPPASourcePortInfo;
    active_port: PPASourcePortInfo;
    n_formats: cuint8;
    formats: PPPAFormatInfo;
  end;

  PPAServerInfo = ^TPAServerInfo;
  TPAServerInfo = record
    user_name: PChar;
    host_name: PChar;
    server_version: PChar;
    server_name: PChar;
    sample_spec: TPASampleSpec;
    default_sink_name: PChar;
    default_source_name: PChar;
    cookie: cuint32;
    channel_map: TPAChannelMap;
  end;

  PPAModuleInfo = ^TPAModuleInfo;
  TPAModuleInfo = record
    index: cuint32;
    name: PChar;
    argument: Pchar;
    n_used: cuint32;
    auto_unload: cint;
    proplist: PPAProplist;
  end;

  PPAClientInfo = ^TPAClientInfo;
  TPAClientInfo = record
    index: cuint32;
    name: PChar;
    owner_module: cuint32;
    driver: Pchar;
    proplist: PPAProplist;
  end;

  PPASinkInputInfo = ^TPASinkInputInfo;
  TPASinkInputInfo = record
    index: cuint32;
    name: PChar;
    owner_module: cuint32;
    client: cuint32;
    sample_spec: TPASampleSpec;
    channel_map: TPAChannelMap;
    volume: TPAChannelVolume;
    buffer_usec: QWord;
    sink_usec: QWord;
    resample_method: PChar;
    driver: PChar;
    mute: cint;
    proplist: PPAProplist;
    corked: cint;
    has_volume: cint;
    volume_writable: cint;
    format: PPAFormatInfo;
  end;


  PPPACardProfileInfo = ^PPACardProfileInfo;
  PPACardProfileInfo = ^TPACardProfileInfo;
  TPACardProfileInfo = object
    name: PChar;
    description: PChar;
    n_sinks: cuint32;
    n_sources: cuint32;
    priority: cint;
  end;
  PPPACardProfileInfo2 = ^PPACardProfileInfo2;
  PPACardProfileInfo2 = ^TPACardProfileInfo2;
  TPACardProfileInfo2 = object(TPACardProfileInfo)
    available: cint;
  end;

  PPACardPortInfo = ^TPACardPortInfo;
  TPACardPortInfo = record
    name: pchar;
    description: pchar;
    priority: cuint32;
    available: cint;
    direction: cint;
    n_profiles: cuint32;
    profiles: PPPACardProfileInfo;
    proplist: PPAProplist;
    latency_offset: Int64;
    profiles2: PPPACardProfileInfo2;
    availability_group: PChar;
    type_: cuint32;
  end;

  PPACardInfo = ^TPACardInfo;
  TPACardInfo = record
    index: cuint32;
    name: PChar;
    owner_module: cuint32;
    driver: PChar;
    n_profiles: cuint32;
    profiles: PPACardProfileInfo;
    active_profile: PPACardProfileInfo;
    proplist: PPAProplist;
    n_ports: cuint32;
    ports: PPPACardProfileInfo;
    profiles2: PPPACardProfileInfo2;
    active_profile2: PPACardProfileInfo2;
  end;

  PPASourceOutputInfo = ^TPASourceOutputInfo;
  TPASourceOutputInfo = record
    index: cuint32;
    name: PChar;
    owner_module: cuint32;
    client: cuint32;
    sample_spec: TPASampleSpec;
    channel_map: TPAChannelMap;
    buffer_usec: QWord;
    source_usec: QWord;
    resample_method: PChar;
    driver: PChar;
    proplist: PPAProplist;
    corked: cint;
    volume: TPAChannelVolume;
    has_volume: cint;
    volume_writable: cint;
    format: PPAFormatInfo;
  end;

  TPAAutoloadType = (alSink = 0, alSource = 1);

  PPAAutoloadInfo = ^TPAAutoloadInfo;
  TPAAutoloadInfo = record
    index: cuint32;
    name: Pchar;
    type_: TPAAutoloadType;
    module: PChar;
    argument: PChar;
  end;

  PPAStatInfo = ^TPAStatInfo;
  TPAStatInfo = record
    memblock_total,
    memblock_total_size,
    memblock_allocated,
    memblock_allocated_size,
    scache_size: cuint32;
  end;

  PPASampleInfo = ^TPASampleInfo;
  TPASampleInfo = record
    index: cuint32;
    name: PChar;
    volume: TPAChannelVolume;
    sample_spec: TPASampleSpec;
    channel_map: TPAChannelMap;
    duration: QWord;
    bytes: cuint32;
    lazy: cint;
    filename: PChar;
    proplist: PPAProplist;
  end;


  { TPAContext }

  TPASinkInfoCallback = procedure(AContext: PPAContext; AInfo: PPASinkInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPASourceInfoCallback = procedure(AContext: PPAContext; AInfo: PPASourceInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPAServerInfoCallback = procedure(AContext: PPAContext; AInfo: PPAServerInfo; userdata: Pointer); cdecl;
  TPAModuleInfoCallback = procedure(AContext: PPAContext; AInfo: PPAModuleInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPAContextIndexCallback = procedure(AContext: PPAContext; AIndex: cuint32; userdata: Pointer); cdecl;
  TPAContextStringCallback = procedure(AContext: PPAContext; ASuccess: cint; AResponse: PChar; userdata: Pointer); cdecl;
  TPAClientInfoCallback = procedure(AContext: PPAContext; AInfo: PPAClientInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPASinkInputInfoCallback = procedure(AContext: PPAContext; AInfo: PPASinkInputInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPACardInfoCallback = procedure(AContext: PPAContext; AInfo: PPACardInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPASourceOutputInfoCallback = procedure(AContext: PPAContext; AInfo: PPASourceOutputInfo; aEOL: Integer; userdata: Pointer); cdecl;
  //TPAAutoloadInfoCallback = procedure(AContext: PPAContext; AInfo: PPASourceOutputInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPAStatInfoCallback = procedure(AContext: PPAContext; AInfo: PPAStatInfo; aEOL: Integer; userdata: Pointer); cdecl;
  TPASampleInfoCallback = procedure(AContext: PPAContext; AInfo: PPASampleInfo; aEOL: Integer; userdata: Pointer); cdecl;

  {
     you can use TPAContext(myVar^) to access these methods.
     or pulse_introspect.TPAContext(myVar^) depending on your unit uses order
  }
  // PPAContextIntrospect = ^TPAContext; defined below
  TPAContext = object(pulse_context.TPAContext)
    // SINK
    function GetSinkInfoList(ACB: TPASinkInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetSinkInfoByName(AName: String; ACB: TPASinkInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetSinkInfoByIndex(AIndex: Integer; ACB: TPASinkInfoCallback; AUserdata: Pointer): PPAOperation;
    function SetSinkVolumeByIndex(AIndex: Integer; AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSinkVolumeByName(AName: String; AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSinkMuteByIndex(AIndex: Integer; AMute: Cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSinkMuteByName(AName: String; AMute: Cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SuspendSinkByIndex(AIndex: Integer; ASuspend: cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SuspendSinkByName(AName: String; ASuspend: cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSinkPortByIndex(AIndex: Integer; APort: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSinkPortByName(AName: String; APort: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // SOURCE
    function GetSourceInfoList(ACB: TPASourceInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetSourceInfoByName(AName: String; ACB: TPASourceInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetSourceInfoByIndex(AIndex: Integer; ACB: TPASourceInfoCallback; AUserdata: Pointer): PPAOperation;
    function SetSourceVolumeByIndex(AIndex: Integer; AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSourceVolumeByName(AName: String; AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSourceMuteByIndex(AIndex: Integer; AMute: Cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSourceMuteByName(AName: String; AMute: Cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SuspendSourceByIndex(AIndex: Integer; ASuspend: cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SuspendSourceByName(AName: String; ASuspend: cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSourcePortByIndex(AIndex: Integer; APort: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSourcePortByName(AName: String; APort: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // SERVER
    function GetServerInfo(ACB: TPAServerInfoCallback; AUserdata: Pointer): PPAOperation;
    // MODULE
    function GetModuleInfoList(ACB: TPAModuleInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetModuleInfo(AIndex: Integer; ACB: TPAModuleInfoCallback;
      AUserdata: Pointer): PPAOperation;
    function LoadModule(AName: String; AArgument: String; ACB: TPAContextIndexCallback; AUserdata: Pointer): PPAOperation;
    function UnloadModule(AIndex: cuint32; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // CONTEXT version 15+
    //function SendMessageToObject(ARecipientName: String; AMessage: String; AMessageParameters: String; ACB: TPAContextStringCallback; AUserdata: Pointer): PPAOperation;
    // CLIENT
    function GetClientInfoList(ACB: TPAClientInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetClientInfo(AIndex: Integer; ACB: TPAClientInfoCallback; AUserdata: Pointer): PPAOperation;
    function KillClient(AIndex: Integer; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // SINK INPUT
    function GetSinkInputInfoList(ACB: TPASinkInputInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetSinkInputInfo(AIndex: Integer; ACB: TPASinkInputInfoCallback; AUserdata: Pointer): PPAOperation;
    function MoveSinkInputByName(AIndex: Integer; ASinkName: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function MoveSinkInputByIndex(AIndex: Integer; ASinkIndex: cuint32; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSinkInputVolume(AIndex: Integer; AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSinkInputMute(AIndex: Integer; AMute: cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function KillSinkInput(AIndex: Integer; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // CARD INFO
    function GetCardInfoList(ACB: TPACardInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetCardInfoByName(AName: String; ACB: TPACardInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetCardInfoByIndex(AIndex: Integer; ACB: TPACardInfoCallback; AUserdata: Pointer): PPAOperation;
    // CARD PROFILE
    function SetCardProfileByIndex(AIndex: Integer; AProfile: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetCardProfileByName(AName: String; AProfile: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // CARD PORT
    function SetPortLatencyOffset(ACardName: String; APortName: String; AOffset: Int64; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // SOURCE OUTPUT
    function GetSourceOutputInfoList(ACB: TPASourceOutputInfo; AUserdata: Pointer): PPAOperation;
    function GetSourceOutputInfo(AIndex: Integer; ACB: TPASourceOutputInfo; AUserdata: Pointer): PPAOperation;
    function MoveSourceOutputByName(AIndex: Integer; ASourceName: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function MoveSourceOutputByIndex(AIndex: Integer; ASourceIndex: cuint32; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSourceOutputVolume(AIndex: Integer; AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function SetSourceOutputMute(AIndex: Integer; AMute: cint; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    function KillSourceOutput(AIndex: Integer; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
    // AUTOLOAD is deprecated.
    // STAT
    function GetStat(ACB: TPAStatInfoCallback; AUserdata: Pointer): PPAOperation;
    //SAMPLE INFO
    function GetSampleInfoList(ACB: TPASampleInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetSampleInfoByName(AName: String; ACB: TPASampleInfoCallback; AUserdata: Pointer): PPAOperation;
    function GetSampleInfoByIndex(AIndex: Integer; ACB: TPASampleInfoCallback; AUserdata: Pointer): PPAOperation;
  end;
  PPAContextIntrospect = ^TPAContext;

  //SINK
  function pa_context_get_sink_info_list(c: PPAContext; cb: TPASinkInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_get_sink_info_by_name(c: PPAContext; name: PChar; cb: TPASinkInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_get_sink_info_by_index(c: PPAContext; index: cuint32; cb: TPASinkInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_volume_by_index(c: PPAContext; index: cuint32; volume: PPAChannelVolume; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_volume_by_name(c: PPAContext; name: pchar; volume: PPAChannelVolume; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_mute_by_index(c: PPAContext; index: cuint32; mute: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_mute_by_name(c: PPAContext; name: pchar; mute: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_suspend_sink_by_index(c: PPAContext; index: cuint32; suspend: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_suspend_sink_by_name(c: PPAContext; name: pchar; suspend: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_port_by_index(c: PPAContext; index: cuint32; port: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_port_by_name(c: PPAContext; name: pchar; port: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  //SOURCE
  function pa_context_get_source_info_list(c: PPAContext; cb: TPASourceInfoCallback; userdata: Pointer): PPAOperation cdecl; external;
  function pa_context_get_source_info_by_name(c: PPAContext; name: PChar; cb: TPASourceInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_get_source_info_by_index(c: PPAContext; index: cuint32; cb: TPASourceInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_volume_by_index(c: PPAContext; index: cuint32; volume: PPAChannelVolume; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_volume_by_name(c: PPAContext; name: pchar; volume: PPAChannelVolume; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_mute_by_index(c: PPAContext; index: cuint32; mute: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_mute_by_name(c: PPAContext; name: pchar; mute: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_suspend_source_by_index(c: PPAContext; index: cuint32; suspend: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_suspend_source_by_name(c: PPAContext; name: pchar; suspend: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_port_by_index(c: PPAContext; index: cuint32; port: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_port_by_name(c: PPAContext; name: pchar; port: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  //SERVER
  function pa_context_get_server_info(c: PPAContext; cb: TPAServerInfoCallback; userdata: Pointer): PPAOperation cdecl; external;
  //MODULE
  function pa_context_get_module_info_list(c: PPAContext; cb: TPAModuleInfoCallback; userdata: Pointer): PPAOperation cdecl; external;
  function pa_context_get_module_info(c: PPAContext; index: cuint32; cb: TPAModuleInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_load_module(c: PPAContext; name: PChar; argument: PChar; ACB: TPAContextIndexCallback; AUserdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_unload_module(c: PPAContext; index: cuint32; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation; cdecl; external;
  //CONTEXT version 15+
  //function pa_context_send_message_to_object(c: PPAContext; ARecipientName: PChar; AMessage: PChar; AMessageParameters: PChar; ACB: TPAContextStringCallback; AUserdata: Pointer): PPAOperation; cdecl; external;
  // CLIENT
  function pa_context_get_client_info_list(c: PPAContext; cb: TPAClientInfoCallback; userdata: Pointer): PPAOperation cdecl; external;
  function pa_context_get_client_info(c: PPAContext; index: cuint32; cb: TPAClientInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_kill_client(c: PPAContext; index: cuint32; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation cdecl; external;
  // SINK INPUT
  function pa_context_get_sink_input_info_list(c: PPAContext; cb: TPASinkInputInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_get_sink_input_info(c: PPAContext; index: cuint32; cb: TPASinkInputInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_move_sink_input_by_name(c: PPAContext; index: cuint32; sink_name: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_move_sink_input_by_index(c: PPAContext; index: cuint32; sink_index: cuint32; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_input_volume(c: PPAContext; index: cuint32; volume: PPAChannelVolume; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_sink_input_mute(c: PPAContext; index: cuint32; mute: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_kill_sink_input(c: PPAContext; index: cuint32; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  // CARD
  function pa_context_get_card_info_list(c: PPAContext; cb: TPACardInfoCallback; userdata: Pointer): PPAOperation cdecl; external;
  function pa_context_get_card_info_by_name(c: PPAContext; name: PChar; cb: TPACardInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_get_card_info_by_index(c: PPAContext; index: cuint32; cb: TPACardInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_card_profile_by_index(c: PPAContext; index: cuint32; profile: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_card_profile_by_name(c: PPAContext; name: pchar; profile: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_port_latency_offset(c: PPAContext; card_name: pchar; port_name: PChar; offset: int64; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  //SOURCE OUTPUT
  function pa_context_get_source_output_info_list(c: PPAContext; cb: TPASourceOutputInfo; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_get_source_output_info(c: PPAContext; index: cuint32; cb: TPASourceOutputInfo; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_move_source_output_by_name(c: PPAContext; index: cuint32; source_name: PChar; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_move_source_output_by_index(c: PPAContext; index: cuint32; source_index: cuint32; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_output_volume(c: PPAContext; index: cuint32; volume: PPAChannelVolume; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_set_source_output_mute(c: PPAContext; index: cuint32; mute: cint; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_kill_source_output(c: PPAContext; index: cuint32; cb: TPAContextSuccessCB; userdata: Pointer): PPAOperation; cdecl; external;
  // STAT
  function pa_context_stat(c: PPAContext; cb: TPAStatInfoCallback; userdata: Pointer): PPAOperation cdecl; external;
  // SAMPLE INFO
  function pa_context_get_sample_info_list(c: PPAContext; cb: TPASampleInfoCallback; userdata: Pointer): PPAOperation cdecl; external;
  function pa_context_get_sample_info_by_name(c: PPAContext; name: PChar; cb: TPASampleInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;
  function pa_context_get_sample_info_by_index(c: PPAContext; index: cuint32; cb: TPASampleInfoCallback; userdata: Pointer): PPAOperation; cdecl; external;

implementation

{ TPAContext }

function TPAContext.GetSinkInfoList(ACB: TPASinkInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sink_info_list(@Self, ACB, AUserdata);
end;

function TPAContext.GetSinkInfoByName(AName: String; ACB: TPASinkInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sink_info_by_name(@Self, PChar(Aname), ACB, AUserdata);
end;

function TPAContext.GetSinkInfoByIndex(AIndex: Integer;
  ACB: TPASinkInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sink_info_by_index(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.SetSinkVolumeByIndex(AIndex: Integer;
  AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_sink_volume_by_index(@Self, AIndex, AVolume, ACB, AUserdata);
end;

function TPAContext.SetSinkVolumeByName(AName: String;
  AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_set_sink_volume_by_name(@Self, PChar(AName), AVolume, ACB, AUserdata);
end;

function TPAContext.SetSinkMuteByIndex(AIndex: Integer; AMute: Cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_sink_mute_by_index(@Self, AIndex, AMute, ACB, AUserdata);
end;

function TPAContext.SetSinkMuteByName(AName: String; AMute: Cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_sink_mute_by_name(@Self, PChar(AName), AMute, ACB, AUserdata);
end;

function TPAContext.SuspendSinkByIndex(AIndex: Integer; ASuspend: cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_suspend_sink_by_index(@Self, AIndex, ASuspend, ACB, AUserdata);
end;

function TPAContext.SuspendSinkByName(AName: String; ASuspend: cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_suspend_sink_by_name(@Self, PChar(AName), ASuspend, ACB, AUserdata);

end;

function TPAContext.SetSinkPortByIndex(AIndex: Integer; APort: String;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_sink_port_by_index(@Self, AIndex, PChar(APort), ACB, AUserdata);
end;

function TPAContext.SetSinkPortByName(AName: String; APort: String;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_sink_port_by_name(@Self, PChar(AName), PChar(APort), ACB, AUserdata);
end;

function TPAContext.GetSourceInfoList(ACB: TPASourceInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_source_info_list(@Self, ACB, AUserdata);
end;

function TPAContext.GetSourceInfoByName(AName: String;
  ACB: TPASourceInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_source_info_by_name(@Self, PChar(AName), ACB, AUserdata);
end;

function TPAContext.GetSourceInfoByIndex(AIndex: Integer;
  ACB: TPASourceInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_source_info_by_index(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.SetSourceVolumeByIndex(AIndex: Integer;
  AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_set_source_volume_by_index(@Self, AIndex, AVolume, ACB, AUserdata);
end;

function TPAContext.SetSourceVolumeByName(AName: String;
  AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_set_source_volume_by_name(@Self, Pchar(AName), AVolume, ACB, AUserdata);
end;

function TPAContext.SetSourceMuteByIndex(AIndex: Integer; AMute: Cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_source_mute_by_index(@Self, AIndex, AMute, ACB, AUserdata);

end;

function TPAContext.SetSourceMuteByName(AName: String; AMute: Cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_source_mute_by_name(@Self, PChar(AName), AMute, ACB, AUserdata);

end;

function TPAContext.SuspendSourceByIndex(AIndex: Integer; ASuspend: cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_suspend_source_by_index(@Self, AIndex, ASuspend, ACB, AUserdata);
end;

function TPAContext.SuspendSourceByName(AName: String; ASuspend: cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_suspend_source_by_name(@Self, PChar(AName), ASuspend, ACB, AUserdata);
end;

function TPAContext.SetSourcePortByIndex(AIndex: Integer; APort: String;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_source_port_by_index(@Self, AIndex, PChar(APort), ACB, AUserdata);
end;

function TPAContext.SetSourcePortByName(AName: String; APort: String;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_source_port_by_name(@Self, PChar(AName), PChar(APort), ACB, AUserdata);
end;

function TPAContext.GetServerInfo(ACB: TPAServerInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_server_info(@Self, ACB, AUserdata);
end;

function TPAContext.GetModuleInfoList(ACB: TPAModuleInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_module_info_list(@Self, ACB, AUserdata);
end;

function TPAContext.GetModuleInfo(AIndex: Integer;
  ACB: TPAModuleInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_module_info(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.LoadModule(AName: String; AArgument: String;
  ACB: TPAContextIndexCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_load_module(@Self, PChar(AName), PChar(AArgument), ACB, AUserdata);
end;

function TPAContext.UnloadModule(AIndex: cuint32;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_unload_module(@Self, AIndex, ACB, AUserdata);
end;

{function TPAContext.SendMessageToObject(ARecipientName: String;
  AMessage: String; AMessageParameters: String; ACB: TPAContextStringCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_send_message_to_object(@Self, PChar(ARecipientName), PChar(AMessage), PChar(AMessageParameters), ACB, AUserdata);
end;}

function TPAContext.GetClientInfoList(ACB: TPAClientInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_client_info_list(@Self, ACB, AUserdata);

end;

function TPAContext.GetClientInfo(AIndex: Integer;
  ACB: TPAClientInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_client_info(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.KillClient(AIndex: Integer; ACB: TPAContextSuccessCB;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_kill_client(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.GetSinkInputInfoList(ACB: TPASinkInputInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sink_input_info_list(@Self, ACB, AUserdata);
end;

function TPAContext.GetSinkInputInfo(AIndex: Integer;
  ACB: TPASinkInputInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sink_input_info(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.MoveSinkInputByName(AIndex: Integer;
  ASinkName: String; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_move_sink_input_by_name(@Self, AIndex, PChar(ASinkName), ACB, AUserdata);
end;

function TPAContext.MoveSinkInputByIndex(AIndex: Integer;
  ASinkIndex: cuint32; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_move_sink_input_by_index(@Self, AIndex, ASinkIndex, ACB, AUserdata);
end;

function TPAContext.SetSinkInputVolume(AIndex: Integer;
  AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_set_sink_input_volume(@Self, AIndex, AVolume, ACB, AUserdata);
end;

function TPAContext.SetSinkInputMute(AIndex: Integer; AMute: cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_sink_input_mute(@Self, AIndex, AMute, ACB, AUserdata);
end;

function TPAContext.KillSinkInput(AIndex: Integer;
  ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_kill_sink_input(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.GetCardInfoList(ACB: TPACardInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_card_info_list(@Self, ACB, AUserdata);
end;

function TPAContext.GetCardInfoByName(AName: String;
  ACB: TPACardInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_card_info_by_name(@Self, PChar(AName), ACB, AUserdata);
end;

function TPAContext.GetCardInfoByIndex(AIndex: Integer;
  ACB: TPACardInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_card_info_by_index(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.SetCardProfileByIndex(AIndex: Integer;
  AProfile: String; ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_card_profile_by_index(@Self,AIndex, PChar(AProfile), ACB, AUserdata);
end;

function TPAContext.SetCardProfileByName(AName: String; AProfile: String;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_card_profile_by_name(@Self, PChar(AName), PChar(AProfile), ACB, AUserdata);
end;

function TPAContext.SetPortLatencyOffset(ACardName: String;
  APortName: String; AOffset: Int64; ACB: TPAContextSuccessCB;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_port_latency_offset(@Self,PChar(ACardName), PChar(APortName), AOffset ,ACB, AUserdata);
end;

function TPAContext.GetSourceOutputInfoList(ACB: TPASourceOutputInfo;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_source_output_info_list(@Self, ACB, AUserdata);
end;

function TPAContext.GetSourceOutputInfo(AIndex: Integer;
  ACB: TPASourceOutputInfo; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_source_output_info(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.MoveSourceOutputByName(AIndex: Integer;
  ASourceName: String; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_move_source_output_by_name(@Self, Aindex, PChar(ASourceName), ACB, AUserdata);
end;

function TPAContext.MoveSourceOutputByIndex(AIndex: Integer;
  ASourceIndex: cuint32; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_move_source_output_by_index(@Self, Aindex, ASourceIndex, ACB, AUserdata);
end;

function TPAContext.SetSourceOutputVolume(AIndex: Integer;
  AVolume: PPAChannelVolume; ACB: TPAContextSuccessCB; AUserdata: Pointer
  ): PPAOperation;
begin
  Result := pa_context_set_source_output_volume(@Self, AIndex, AVolume, ACB, AUserdata);
end;

function TPAContext.SetSourceOutputMute(AIndex: Integer; AMute: cint;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_set_source_output_mute(@Self, AIndex, AMute, ACB, AUserdata);
end;

function TPAContext.KillSourceOutput(AIndex: Integer;
  ACB: TPAContextSuccessCB; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_kill_source_output(@Self, AIndex, ACB, AUserdata);
end;

function TPAContext.GetStat(ACB: TPAStatInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_stat(@Self, ACB, AUserdata);
end;

function TPAContext.GetSampleInfoList(ACB: TPASampleInfoCallback;
  AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sample_info_list(@Self, ACB, AUserdata);
end;

function TPAContext.GetSampleInfoByName(AName: String;
  ACB: TPASampleInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sample_info_by_name(@Self, PChar(AName), ACB, AUserdata);
end;

function TPAContext.GetSampleInfoByIndex(AIndex: Integer;
  ACB: TPASampleInfoCallback; AUserdata: Pointer): PPAOperation;
begin
  Result := pa_context_get_sample_info_by_index(@Self, AIndex, ACB, AUserdata);
end;

end.

