#if defined _xbuild_included
  #endinput
#endif
#define _xbuild_included

#if defined BUILD_ID
int GetBuildVersion(char[] buf, int maxlen)
{
#if defined PLUGIN_VERSION
    return Format(buf, maxlen, "%s_%d", PLUGIN_VERSION, BUILD_ID);
#else
    return IntToString(BUILD_ID, buf, maxlen);
#endif
}
#else
int GetBuildVersion(char[] buf, int maxlen)
{
#if defined PLUGIN_VERSION
    return strcopy(buf, maxlen, PLUGIN_VERSION);
#else
    buf[0] = '\x0';
    return 0;
#endif
}
#endif

public void __OnVersionChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
    char version[64];
    if (GetBuildVersion(version, sizeof(version)) <= 0) {
        return;
    }
    
    if (StrEqual(version, newValue)) {
        return;
    }

    convar.SetString(version);
}

stock ConVar CreateVersionConVar(const char[] name, const char[] prefix="sm")
{
    char cvarname[64];
    Format(cvarname, sizeof(cvarname), "%s_%s_version", prefix, name);

    char version[64];
    GetBuildVersion(version, sizeof(version));

    ConVar ver = FindConVar(cvarname);
    if (ver == null) {
        return CreateConVar(cvarname, version, "", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
    }

    ver.AddChangeHook(__OnVersionChange);
    ver.SetString(version);
    return ver;
}
