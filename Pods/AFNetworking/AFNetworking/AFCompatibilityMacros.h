// AFCompatibilityMacros.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )


#ifndef AFCompatibilityMacros_h
#define AFCompatibilityMacros_h

#ifdef API_AVAILABLE
    #define AF_API_AVAILABLE(...) API_AVAILABLE(__VA_ARGS__)
#else
    #define AF_API_AVAILABLE(...)
#endif // API_AVAILABLE

#ifdef API_UNAVAILABLE
    #define AF_API_UNAVAILABLE(...) API_UNAVAILABLE(__VA_ARGS__)
#else
    #define AF_API_UNAVAILABLE(...)
#endif // API_UNAVAILABLE

#if __has_warning("-Wunguarded-availability-new")
    #define AF_CAN_USE_AT_AVAILABLE 1
#else
    #define AF_CAN_USE_AT_AVAILABLE 0
#endif

#if ((__IPHONE_OS_VERSION_MAX_ALLOWED && __IPHONE_OS_VERSION_MAX_ALLOWED < 100000) || (__MAC_OS_VERSION_MAX_ALLOWED && __MAC_OS_VERSION_MAX_ALLOWED < 101200) ||(__WATCH_OS_MAX_VERSION_ALLOWED && __WATCH_OS_MAX_VERSION_ALLOWED < 30000) ||(__TV_OS_MAX_VERSION_ALLOWED && __TV_OS_MAX_VERSION_ALLOWED < 100000))
    #define AF_CAN_INCLUDE_SESSION_TASK_METRICS 0
#else
    #define AF_CAN_INCLUDE_SESSION_TASK_METRICS 1
#endif

#endif /* AFCompatibilityMacros_h */
