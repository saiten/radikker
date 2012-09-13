/*
 *  RDIPDefines.h
 *  radikker
 *
 *  Created by saiten  on 10/04/09.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

//
// limit setting
//
#define RDIP_CHECK_LOCATION_VIA_3G NO
#define RDIP_CHECK_JAILBREAK       NO

//
// Config keys
//
#define RDIPCONFIG_SETTINGVALUES               @"SettingValues"
#define RDIPCONFIG_SETTINGVALUES_TITLE         @"Title"
#define RDIPCONFIG_SETTINGVALUES_DEFAULTVALUE  @"DefaultValue"
#define RDIPCONFIG_SETTINGVALUES_NAMES         @"Names"
#define RDIPCONFIG_SETTINGVALUES_VALUES        @"Values"

#define RDIPCONFIG_HASHTAGS      @"HashTags"


//
// Setting keys
//
#define RDIPSETTING_ACCESSTOKEN @"SettingAccessToken"
#define RDIPSETTING_SECRETKEY   @"SettingSecretKey"
#define RDIPSETTING_USERID      @"SettingUserID"
#define RDIPSETTING_SCREENNAME  @"SettingScreenName"

#define RDIPSETTING_AUTOREFRESH @"SettingAutoRefresh"
#define RDIPSETTING_INITIALLOAD @"SettingInitialLoad"
#define RDIPSETTING_BUFFERSIZE  @"SettingBufferSize"
#define RDIPSETTING_INITIALPLAY  @"SettingInitialPlay"

#define RDIPSETTING_FIRSTLAUNCH       @"SettingFirstLaunch"
#define RDIPSETTING_FIRSTCONNECTVIA3G @"SettingFirstConnectVia3G"


//
// WebView StyleSheet
//

#define RDIPWEB_DEFAULTHTML_FORMAT @"<!doctype html><html><head>%@</head><body>%@</body></html>"
#define RDIPWEB_DEFAULTHEADER  \
@"<meta name=\"viewport\" content=\"width=280; initial-scale=1.0; maximum-scale=1.0; user-scalable=0\">" \
@"<style type='text/css'>" \
@"  * { font-size: 16px;" \
@"      font-family: sans-serif;" \
@"      word-wrap: break-word; " \
@"      margin: 4px 0 4px 0; }" \
@"  a { color: #4169E1; font-weight: bold; text-decoration: none; } " \
@"  body { background-color: transparent; }" \
@"  #text { color: #222; }" \
@"  #foot { margin-top: 1em; font-size: 12px; color: #555; }" \
@"  #foot a { font-size: 14px; } " \
@"</style>"
