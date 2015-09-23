#ifndef L3GD20_H
#define L3GD20_H

#include <cstddef>
#include <array>


bool gyro_init();

std::array<int16_t, 3> get_gyro_data();


#endif // L3GD20_H
