
#ifndef Easywork_EWLog_h
#define Easywork_EWLog_h

//Log Info

#ifdef DEBUG
#define DBLog(format, ...)    NSLog((@"\n\n>>>当前文件:{%s}\n>>>当前行号:{%d}\n>>>当前函数:{%s}\n"@">>>打印信息:"@"{"format@"}\n\n"), __FILE__, __LINE__,__FUNCTION__, ##__VA_ARGS__)
#define DBError(E) NSLog(@"\n\n>>>当前文件:{%s}\n>>>当前行号:{%d}\n>>>当前函数:{%s}\n"@">>>错误代号:{%ld}\n>>>错误描述:{%@}\n\n", __FILE__, __LINE__,__FUNCTION__,[E code],[E localizedDescription])
#else
#define DBLog(...)
#define DBError(...)
#endif

#endif
