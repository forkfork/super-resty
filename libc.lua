local ffi = require('ffi')
ffi.cdef [[
  int signal(int sig);
  int getppid(void);
  int kill(int pid, int sig);
  int access(const char *pathname, int mode);
]]
