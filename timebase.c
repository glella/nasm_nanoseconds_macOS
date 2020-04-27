#include <mach/mach_time.h>

double timebase() {
    double  ratio;
    mach_timebase_info_data_t tb;

    mach_timebase_info(&tb);
    ratio = tb.numer / tb.denom;

    return ratio;
}