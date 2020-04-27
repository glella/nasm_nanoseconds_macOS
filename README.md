# Measures nanoseconds on macOS using mach_absolute_time and NASM

Small test uses mach_absolute_time to measure elapsed nanoseconds.

Gets start and end times, then calculates duration of a test function that uses nanosleep to simulate 1 second of work.

As mach_absolute_time is hardware dependant, its result needs to be adjusted from the result of calling mach_timebase_info.

mach_timebase_info fills a struct of mach_timebase_info_data_t you provide with a ratio to apply to the elapsed result from mach_absolute_time.
The struct has a numerator and a denominator.

The small C utility function timebase.c gets this struct filled and returns the ratio as a double.
Its result goes into the xmm0 register.

