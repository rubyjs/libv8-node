#warning "This is not a source file -- it exists purely to allow CMake to distinguish between glibc and musl-libc. If you see this message, you are likely doing something incorrectly."

#include <stdlib.h>

#ifndef __GLIBC__
#error "__GLIBC__ is undef -- not glibc!"
#endif

int main() { }

