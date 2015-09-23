#ifndef LSM303DLHC_H
#define LSM303DLHC_H

#include <cstddef>
#include <array>


bool accel_init();
bool mag_init();

std::array<int16_t, 3> get_accel_data();
std::array<int16_t, 3> get_mag_data();


#endif // LSM303DLHC_H
